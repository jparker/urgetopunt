---
layout: post
title: SUM, DISTINCT, and Eagerly-Loaded Associations
tags: rails
---

A common task in application is to list a collection of records along with a
summary such as the sum of a particular attribute across the collection. For
example, imagine we have Job model which has a numeric rate attribute. In a
`jobs#index` action, we might list the jobs in the body of a table, and display
the sum of the rates in the table footer.

```erb
<table>
  <tfoot>
    <tr>
      <td>…</td>
      <td><%= number_to_currency @jobs.total_rate %></td>
    </tr>
  </tfoot>
  <tbody>
    <%= render @jobs %>
  </tbody>
</table>
```

`Job.total_rate` is easy enough to implement:

```ruby
class Job < ApplicationRecord
  def self.total_rate
    sum :rate
  end
end
```

Let's seed the database and prove that this works.

```ruby
class JobTest < ActiveSupport::TestCase
  def test_total_rate_returns_sum_of_rates
    2.times { Job.create! rate: 100 }
    assert_equal 200, Job.total_rate
  end
end
```

```
Running via Spring preloader in process 34676
Run options: --seed 49117

# Running:

.

Finished in 0.027461s, 36.4148 runs/s, 36.4148 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

This test passes. Woo! Great effort, people. Chocolate milks all around. Let's
go home.

Or not…

## Eager Loading and Row Duplication

What if there is a `has_many` association on the Job model? For example, let's
say our Jobs can be assigned to multiple Categories.

```ruby
class Category < ApplicationRecord
  has_and_belongs_to_many :jobs
end

class Job < ApplicationRecord
  has_and_belongs_to_many :categories
end
```

If we are displaying the categories on `jobs#index`, we may want to eagerly
load the categories association to ensure we don't bombard the database with an
additional query for every category.

```ruby
class JobsController < ApplicationController
  def index
    @jobs = Job.includes :categories
  end
end
```

How would `Job.total_rate` behave in this scenario?

```ruby
categories = 2.times { |n| Category.create! name: "category #{n}" }

Job.create! do |job|
  job.rate = 100
  job.categories = categories
end

Job.create! do |job|
  job.rate = 100
end

Job.includes(:categories).total_rate # => 300.0
```

Practically speaking, we know the total rate is 200.0 not 300.0. So what's
going on? Well, here's the SQL that's being executed when we call
`Job.total_rate`:

```sql
SELECT SUM("jobs"."rate") FROM "jobs"
  LEFT OUTER JOIN "categories_jobs" ON "categories_jobs"."job_id" = "jobs"."id"
  LEFT OUTER JOIN "categories" ON "categories"."id" = "categories_jobs"."category_id"
```

What's happening is a row is returned for every existing Job-Category
combination. If a Job belongs to one Category, one row is returned; if a Job
belongs to two Categories, two rows are returned, etc. (Because we are doing a
`LEFT OUTER JOIN`, if a Job belongs to zero Categories, we still get one row
for the Job itself.) Let's look at a different query to see the actual result
set:

```sql
SELECT
  jobs.id AS job_id,
  category.id AS category_id,
  jobs.rate AS rate
FROM jobs
  LEFT OUTER JOIN categories_jobs ON categories_jobs.job_id = jobs.id
  LEFT OUTER JOIN categories ON categories_jobs.category_id = categories.id
```

The result set looks like this:

{:.table.table-bordered.table-striped}
|job_id|category_id|rate|
|1|1|100|
|1|2|100|
|2|NULL|100|

So when we perform the `SUM` the first Job is duplicated. We need
`Job.total_rate` to account for this, but how? First, let's write a test:

```ruby
def test_total_rate_with_duplicate_rows
  categories = 2.times.map { |n| Category.create! name: "category #{n}" }
  Job.create! rate: 100, categories: categories
  Job.create! rate: 100
  assert_equal 200, Job.includes(:categories).total_rate
end
```

…and verify that the test, in fact, fails:

```
Running via Spring preloader in process 34719
Run options: --seed 64383

# Running:

.F

Failure:
JobTest#test_total_rate_with_duplicate_rows [/Users/john/Projects/summable/test/models/job_test.rb:13]:
Expected: 200
  Actual: 300.0


bin/rails test test/models/job_test.rb:9


Finished in 0.080557s, 24.8272 runs/s, 24.8272 assertions/s.

2 runs, 2 assertions, 1 failures, 0 errors, 0 skips
```

Great! Now how do we make the test pass? Well, the goal is to calculate the
`SUM` of the rates for each distinct job in the result set. In other words,
when considering the query that loads the Jobs, we want to calculate the `SUM`
for the Jobs whose IDs are in the original result set.
[ActiveRecord::Base.pluck](http://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pluck)
seems like it might be useful here.

```ruby
def self.total_rate
  unscoped.where(id: distinct.ids).sum :rate
end
```

[ActiveRecord::Base.ids](http://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-ids)
is a shortcut for `pluck :id`. We call
[ActiveRecord::Base.distinct](http://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-distinct)
to return each of the matching IDs only once. Let's rerun the tests, and see if
it works.

```
Running via Spring preloader in process 34924
Run options: --seed 55533

# Running:

..

Finished in 0.085292s, 23.4488 runs/s, 23.4488 assertions/s.

2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

The tests pass, so, huzzah? Well, sort of.

## Using Sub-selects

Let's look in the logs and see the query(ies) that actually get executed.

```sql
SELECT DISTINCT "jobs"."id"
FROM "jobs"
  LEFT OUTER JOIN "categories_jobs" ON "categories_jobs"."job_id" = "jobs"."id"
  LEFT OUTER JOIN "categories" ON "categories"."id" = "categories_jobs"."category_id"
SELECT SUM("jobs"."rate") FROM "jobs" WHERE "jobs"."id" IN (2, 1)
```

Well, we can see why it works, but I have a nagging concern about the way this
works. It's performing two separate queries. The first query looks up the Job
IDs and loads them into an Array. The second query performs the actual `SUM`,
passing the Array of Job IDs in as a parameter. We only have two Jobs in the
database during the test, but what will it look like in production? What if we
have 100,000 Jobs? Well, it will perform the first query, creating an Array of
100,000 IDs, and then it will perform the second query, passing in a
100,000-element Array as a query parameter. Yikes.

The thing is, SQL is a clever language. You don't have to perform two separate
queries, and you don't have to construct an arbitrarily long Array in order to
perform this task, when you can just use a sub-select. The SQL for such a query
might look something like this:

```sql
SELECT SUM(rate)
FROM jobs
WHERE id IN (SELECT DISTINCT id FROM jobs)
```

So what's going on? ActiveRecord is able to generate sub-selects. Why isn't it
doing it here? Well, `pluck` is a special method; it executes immediately and
always returns an Array. We don't actually want to use `pluck` in this
situation. We want to use
[ActiveRecord::Base.select](http://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-select).

```ruby
def self.total_rate
  unscoped.where(id: distinct.select(:id)).sum :rate
end
```

Let's rerun the tests, and make sure it still works:

```
Running via Spring preloader in process 35770
Run options: --seed 48301

# Running:

..

Finished in 0.092239s, 21.6829 runs/s, 21.6829 assertions/s.

2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

Looks good. Now let's check the logs and see the query that gets executed.

```sql
SELECT SUM("jobs"."rate") FROM "jobs"
WHERE "jobs"."id" IN (SELECT DISTINCT "jobs"."id" FROM "jobs")
```

Bingo! There's the sub-select. So does that mean we're done? Well, not quite.

What happened to the `JOIN` clauses?

ActiveRecord provides two different ways for joining additional tables in a
query:
[ActiveRecord::Base.joins](http://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-joins).
and
[ActiveRecord::Base.includes](http://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes).
Which method you choose depends on the reason you are joining the additional
tables. You use `joins` when you just need to join the table in the query in
order to reference columns from that other table. You use `includes` when you
want to eagerly load the referenced association when constructing the result
set, say to avoid an N+1 query problem.

The `joins` method defaults to performing an `INNER JOIN`. Rails 5 added
[ActiveRecord::Base.left_outer_joins](http://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-left_outer_joins)
(aliased as `left_joins`) to perform a `LEFT OUTER JOIN` instead. If you are
using Rails 4.2.x or earlier, you can still perform a `LEFT OUTER JOIN`, but
you have to pass a SQL String to the `joins` call.

```ruby
# Rails 5 and later
Job.joins(:categories)            # INNER JOIN
Job.left_outer_joins(:categories) # LEFT OUTER JOIN

# Rails 4.2.x and earlier
Job.joins(:categories)            # INNER JOIN
Job.joins(<<SQL)                  # LEFT OUTER JOIN
LEFT OUTER JOIN categories_jobs ON categories_jobs.job_id = jobs.id
LEFT OUTER JOIN categories ON categories_jobs.category_id = categories.id
SQL
```

The `includes` method always performs an `OUTER JOIN`.

ActiveRecord omits the `JOIN` clauses from the sub-select, because we created
them using `includes`. We chose `includes` because we wanted to eagerly load
the Categories when we loaded the Job. This makes sense for the goal of loading
and displaying a collection of Jobs, but there's no reason to load the
Categories in `Job.total_rate` because we aren't instantiating the Jobs; we're
just performing a `SUM`. That was good enough to make the test pass, but will
that always work?

## Eager Loading and Conditions

Let's consider a new scenario. This time, instead of calculating the total rate
for all Jobs, let's calculate the total rate for Jobs that belong to a
particular category. Here's a test to demonstrate:

```ruby
def test_total_rate_with_search_parameters
  categories = 2.times.map { |n| Category.create! name: "category #{n}" }
  Job.create! rate: 100, categories: categories
  Job.create! rate: 100
  assert_equal 100, Job.includes(:categories)
    .where(categories: { name: 'category 1' })
    .total_rate
end
```

In this case, we are filtering Jobs for those that belong to Categories with
the name "category 1". As only one Job belongs to that Category, we expect the
total rate to be 100. Let's run the test and see what happens.

```
Running via Spring preloader in process 36190
Run options: --seed 64894

# Running:

..E

Error:
JobTest#test_total_rate_with_search_parameters:
ActiveRecord::StatementInvalid: PG::UndefinedTable: ERROR:  missing FROM-clause entry for table "categories"
LINE 1: ...IN (SELECT DISTINCT "jobs"."id" FROM "jobs" WHERE "categorie...
                                                             ^
: SELECT SUM("jobs"."rate") FROM "jobs" WHERE "jobs"."id" IN (SELECT DISTINCT "jobs"."id" FROM "jobs" WHERE "categories"."name" = $1)
    app/models/job.rb:7:in `total_rate'
    test/models/job_test.rb:22:in `test_total_rate_with_search_parameters'


bin/rails test test/models/job_test.rb:16



Finished in 0.094740s, 31.6657 runs/s, 21.1104 assertions/s.

3 runs, 2 assertions, 0 failures, 1 errors, 0 skips
```

Pay particular attention to the query that gets executed:

```sql
SELECT SUM("jobs"."rate") FROM "jobs"
WHERE "jobs"."id" IN (SELECT DISTINCT "jobs"."id" FROM "jobs" WHERE "categories"."name" = 'category 1')
```

Recall that in the previous example, ActiveRecord has simplified the sub-select
by removing the `JOIN` clauses. That wasn't a problem before, but now, in this
scenario, we need the `JOIN` clauses to be preserved within the sub-select to
ensure the categories table is available for our search.

Earlier we talked about `joins` and `left_outer_joins`. If we used those
instead of `includes`, would the `JOIN` clauses be preserved? Lets' modify the
test and find out.

```ruby
def test_total_rate_with_search_parameters
  categories = 2.times.map { |n| Category.create! name: "category #{n}" }
  Job.create! rate: 100, categories: categories
  Job.create! rate: 100
  assert_equal 100, Job.left_outer_joins(:categories)
    .where(categories: { name: 'category 1' })
    .total_rate
end
```

And here's the test result:

```
Running via Spring preloader in process 37200
Run options: --seed 51677

# Running:

...

Finished in 0.115139s, 26.0555 runs/s, 26.0555 assertions/s.

3 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

Hey! It works. So is that enough? No. As mentioned before, the point of using
`includes` is to eagerly load associations. If we called
`Job.left_outer_joins(:categories)` from a controller action, the categories
table will be available in `Job.total_rate`, but the Categories will not be
eagerly loaded. If we start displaying Categories, we will set off a flurry of
additional SQL queries to load the Categories one by one --- the stereotypical
N+1 query.

Okay, so we really do want to use `includes`. How can we get `Job.total_rate`
to work? Well, as it happens, an ActiveRecord::Relation has methods for
introspection into the parameters of its query. In this case, there's an
accessor method named `includes_values`; each time you call `includes` the
associations you reference are added to `includes_values`.

```ruby
Job.includes(:categories).includes_values # => [:categories]
```

{:.alert.alert-warning}
**WARNING** The `includes_values` method is not mentioned in the Rails API
documentation, so it may be that it's not meant for public use. I can't promise
this will always work. We're living dangerously.

What if we modified `Job.total_rate` to use `includes_values` and
`left_outer_joins`?

```ruby
def self.total_rate
  subquery = distinct.select :id
  if !subquery.includes_values.empty?
    subquery = subquery.left_outer_joins subquery.includes_values
  end
  unscoped.where(id: subquery).sum :rate
end
```

We rollback the test to the previous version using `includes` instead of
`left_outer_joins` and rerun the tests.

```
Running via Spring preloader in process 37510
Run options: --seed 28323

# Running:

...

Finished in 0.097461s, 30.7815 runs/s, 30.7815 assertions/s.

3 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

It passed. To understand why, let's look at the SQL that was generated:

```sql
SELECT SUM("jobs"."rate") FROM "jobs"
WHERE "jobs"."id" IN (
  SELECT DISTINCT "jobs"."id" FROM "jobs"
    LEFT OUTER JOIN "categories_jobs" ON "categories_jobs"."job_id" = "jobs"."id"
    LEFT OUTER JOIN "categories" ON "categories"."id" = "categories_jobs"."category_id"
  WHERE "categories"."name" = 'category 1'
)
```

Fantastic! So, we're done right? Right? Sadly, no.

## Eager Loading, Conditions, and Pagination

Even in a modest-sized application, there are times when you want to paginate a
collection to keep response times and memory usage low. If our database has
100,000 Jobs, we don't want to instantiate them all at once. But that doesn't
mean we don't want to consider the entire result set in the footer. We may only
be display 25 Jobs per page, but we probably want to know the total rate for
all the matching Jobs.

The simplest way to paginate results is by adding `LIMIT` and `OFFSET` clauses
to our query. (Often this is [not the most efficient
way](https://www.citusdata.com/blog/2016/03/30/five-ways-to-paginate/), but it
is the most common, and so this is the approach I will be addressing below.)
The [kaminari](https://github.com/amatsuda/kaminari) gem is my go-to gem for
adding pagination to a Rails application.

```ruby
2.times { Job.create! }
Job.count                # => 2
Job.page(1).per(1).count # => 1
```

So our goal is to ensure that `Job.total_rate` performs the `SUM` across all
matching jobs regardless of what page we are looking at. Let's write a test to
see what happens when we use pagination.

```ruby
def test_total_rate_with_joins_and_pagintation
  categories = 2.times.map { |n| Category.create! name: "category #{n}" }
  Job.create! rate: 100, categories: categories
  Job.create! rate: 100, categories: categories
  assert_equal 200, Job.includes(:categories)
    .where(categories: { name: 'category 1' })
    .page(1).per(1)
    .total_rate
end
```

We use `per(1)` to restrict our query to one Job per page, and `page(1)` to
return the first page of results.

```
Running via Spring preloader in process 37954
Run options: --seed 43188

# Running:

...F

Failure:
JobTest#test_total_rate_with_joins_and_pagination [/Users/john/Projects/summable/test/models/job_test.rb:29]:
Expected: 200
  Actual: 100.0


bin/rails test test/models/job_test.rb:25


Finished in 0.125655s, 31.8333 runs/s, 31.8333 assertions/s.

4 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

Curses! As feared, `Job.total_rate` looks at the current page of results rather
than the entire result set. Let's look at the SQL to see what's going on.

```sql
SELECT SUM("jobs"."rate") FROM "jobs"
WHERE "jobs"."id" IN (
  SELECT  DISTINCT "jobs"."id" FROM "jobs"
    LEFT OUTER JOIN "categories_jobs" ON "categories_jobs"."job_id" = "jobs"."id"
    LEFT OUTER JOIN "categories" ON "categories"."id" = "categories_jobs"."category_id"
  WHERE "categories"."name" = 'category 1'
  LIMIT 1
  OFFSET 1
)
```

Those `LIMIT` and `OFFSET` clauses are limiting the `SUM`. What's a developer
to do?

Well,
[ActiveRecord::Base.except](http://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-except)
can be very useful here. The `except` method allows us to skip certain types of
query conditions. In this case, we want to drop the `LIMIT` and `OFFSET`
conditions. Let's rewrite `Job.total_rate` one more time.

```ruby
def self.total_rate
  summable.sum :rate
end

def self.summable
  subquery = except :limit, :offset
  if !subquery.includes_values.empty?
    subquery = subquery.left_outer_joins subquery.includes_values
  end
  unscoped.where id: subquery.distinct.select(:id)
end
```

I'm now using `except` to drop the `LIMIT` and `OFFSET` clauses. While I'm at
it, I'm also extracting a new method, `Job.summable`. `Job.total_rate` was
becoming a little hairy for my tastes. I also moved `distinct.select(:id)`
because I felt the result was a bit more intuitive.

This is the moment of truth. Let's run the tests.

```
Running via Spring preloader in process 41410
Run options: --seed 2220

# Running:

....

Finished in 0.121656s, 32.8797 runs/s, 32.8797 assertions/s.

4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

Hooplah? Yes, hooplah. "Give me a milk, Lou. Chocolate."

<iframe width="560" height="315" src="https://www.youtube.com/embed/iFNLbAs3KAU" frameborder="0" allowfullscreen></iframe>

## Summary

In closing, let's look at all the code together.

```ruby
# app/controllers/jobs_controller.rb
class JobsController < ApplicationController
  def index
    @jobs = Job.includes :categories
  end
end

# app/models/category.rb
class Category < ApplicationRecord
  has_and_belongs_to_many :jobs
end

# app/models/job.rb
class Job < ApplicationRecord
  has_and_belongs_to_many :categories

  def self.total_rate
    summable.sum :rate
  end

  def self.summable
    subquery = except :limit, :offset
    if !subquery.includes_values.empty?
      subquery = subquery.left_outer_joins subquery.includes_values
    end
    unscoped.where id: subquery.distinct.select(:id)
  end
end

# test/modesl/job_test.rb
require 'test_helper'

class JobTest < ActiveSupport::TestCase
  def test_total_rate_returns_sum_of_rates
    2.times { Job.create! rate: 100 }
    assert_equal 200, Job.total_rate
  end

  def test_total_rate_with_duplicate_rows
    categories = 2.times.map { |n| Category.create! name: "category #{n}" }
    Job.create! rate: 100, categories: categories
    Job.create! rate: 100
    assert_equal 200, Job.includes(:categories).total_rate
  end

  def test_total_rate_with_search_parameters
    categories = 2.times.map { |n| Category.create! name: "category #{n}" }
    Job.create! rate: 100, categories: categories
    Job.create! rate: 100
    assert_equal 100, Job.includes(:categories)
      .where(categories: { name: 'category 1' })
      .total_rate
  end

  def test_total_rate_with_joins_and_pagintation
    categories = 2.times.map { |n| Category.create! name: "category #{n}" }
    Job.create! rate: 100, categories: categories
    Job.create! rate: 100, categories: categories
    assert_equal 200, Job.includes(:categories)
      .where(categories: { name: 'category 1' })
      .page(1).per(1)
      .total_rate
  end
end
```
