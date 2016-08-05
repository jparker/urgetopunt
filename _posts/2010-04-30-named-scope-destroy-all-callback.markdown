---
title: Rails 2.3, named_scope, destroy_all and callback confusion
layout: post
---

### Background

I was recently working on a Rails 2.3.5 application when I found myself
stumped on some perplexing behavior that arose when using a named scope,
the <code>#destroy_all</code> method and an after destroy callback fired
by an ActiveRecord observer. Let's begin with the models. There are
Asset and User models. The assets table's columns include the integer
<code>file_size</code> and timestamp <code>delete_after</code>. There
is a named scope, <code>expired</code>, which returns all assets for
which the value of <code>delete_after</code> is in the past. Assets
belong to users.

```ruby
class Asset < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  named_scope :expired, lambda { {:conditions => ['delete_after < ?', Time.now]} }
end
# == Schema information
# ...
# user_id      :integer     not null
# file_size    :integer     default(0), not null
# delete_after :datetime
# ...
```

Users have many assets. The users table has a large integer column,
<code>current_disk_usage</code>, which holds the denormalized sum of
the file sizes of the assets belonging to each user. There is an
instance method, <code>#recalculate_disk_usage!</code>, which
triggers the User instance to update <code>current_disk_usage</code>
be recalculating the sum of the user's assets.

```ruby
class User < ActiveRecord::Base
  has_many :assets

  def recalculate_disk_usage!
    update_attribute(:current_disk_usage, assets.sum(:file_size))
  end
end
# == Schema information
# ...
# current_disk_usage :integer(12)   default(0), not null
# ...
```

There is an AssetObserver class which triggers
<code>User#recalculate_disk_usage!</code> any time an asset record is
created, updated or destroyed. (The implementation show below is
inefficient, and one workaround to the problem discussed in this article
was to make the observer a bit gentler on the database. That version can
be found at the bottom of the article.)

```ruby
class AssetObserver < ActiveRecord::Observer
  def after_create(asset)
    asset.user.recalculate_disk_usage! unless asset.file_size.zero?
  end

  def after_update(asset)
    asset.user.recalculate_disk_usage! if asset.file_size_changed?
  end

  def after_destroy(asset)
    asset.user.recalculate_disk_usage!
  end
end
```

### The problem

The application in question must periodically purge asset records which
have expired (where <code>delete_after</code> is in the past). This is
accomplished with a Rake task which sends <code>#destroy_all</code> to
the <code>Asset.expired</code> named scope.

```ruby
task :purge_expired => :environment do
  Asset.expired.destroy_all
end
```

And this is where the confusion set in. Whenever I manually created,
updated or destroyed an asset the asset observer kicked in as expected
and the user's current disk usage was updated accordingly. Whenever I
ran the <code>purge_expired</code> Rake task, the correct assets were
destroyed, but the user's current disk usage would get set to zero. If I
manually created, updated or destroyed another asset the current disk
usage would once again be set to the correct, up-to-date value. It was
time to see what SQL was actually being run, so I opened up the log
file.

```sql
DELETE FROM "assets" WHERE "id" = 2
SELECT sum("assets".file_size) AS sum_file_size FROM "assets" WHERE (("assets".delete_after < '2010-04-30 06:41:20.755388') AND ("assets".user_id = 5))
UPDATE "users" SET "updated_at" = '2010-04-30 06:41:21.189777', "current_disk_usage" = 0 WHERE "id" = 5
```

*J'accuse!* The <code>DELETE</code> statement on the first line removes
the record from the assets table, and the <code>UPDATE</code> on the
last line shows the user's disk usage being set to zero. But what's up
with the <code>SELECT</code> in the middle? It's calculating the sum of
the file sizes of the user's assets, but it's limited the sum to those
assets which have expired -- look at the first half of the
<code>WHERE</code> clause. For some reason the conditions imposed by the
<code>Asset.expired</code> named scope are filtering into the call to
<code>user.assets.sum(:file_size)</code>. I took a look at the
implementation of <code>ActiveRecord::Base.destroy_all</code> for a
clue.

```ruby
# File activerecord/lib/active_record/base.rb, line 876
def destroy_all(conditions = nil)
  find(:all, :conditions => conditions).each { |object| object.destroy }
end
```

Not really an obvious answer, but it helped to steer my thinking.
<code>Asset.expired</code> returns an instance of
<code>ActiveRecord::NamedScope::Scope</code>. Sending
<code>#destroy_all</code> to that scope calls
<code>ActiveRecord::Base.find(:all)</code> which returns an array of
<code>Asset</code> instances. We then iterate over that array, sending
<code>#destroy</code> to each asset. For each asset, after
<code>#destroy</code> runs,
<code>AssetObserver#after_destroy(asset)</code> is called which calls
<code>asset.user.recalculate_disk_usage!</code> which in turn calls
<code>asset.user.assets.sum(:file_size)</code>.

### A workaround

Okay, but I still didn't know why the <code>expired</code> named scope
conditions at the beginning of the process were showing up again when
calling <code>user.assets</code> near the end of the process. However I
had a hunch the call to <code>ActiveRecord::Base.find</code> had
something to do with it, so to test this hunch I modified the Rake task,
removing the call to <code>destroy_all</code> and instead iterating
over the scope directly.

```ruby
task :purge_expired => :environment do
  Asset.expired.each { |asset| asset.destroy }
end
```

So what happens when I run the Rake task now?

```sql
DELETE FROM "assets" WHERE "id" = 12
SELECT sum("assets".file_size) AS sum_file_size FROM "assets" WHERE ("assets".user_id = 5)
UPDATE "users" SET "updated_at" = '2010-04-30 18:13:41.050527', "current_disk_usage" = 1696416 WHERE "id" = 5
```

*Et voilà!* I don't know what <code>destroy_all</code>'s use of
<code>ActiveRecord::Base.find</code> does that leaks into later elements
of the destruction process. Bypassing <code>destroy_all</code> by
iterating over the named scope directly seems to fix the problem, and to
be honest, while the original version with <code>destroy_all</code>
looked more like idiomatic Rails, the use of <code>each</code> feels
more like idiomatic Ruby, i.e., purer. I think this may be a bug, but
I'd need to get deeper into the guts of Rails' traversal across the
association to be sure. I've only encountered this problem on Rails 2.3.
I haven't tested the Rails 3 release candidate yet.

### A different workaround

But wait, there's more. As I mentioned earlier, the original
implementation of <code>AssetObserver</code> isn't efficient. Here's the
problem: each time an asset record is destroyed, the database is issued
both <code>SELECT SUM</code> and <code>UPDATE</code> statements. The
latter is unavoidable, but is the former strictly necessary?
ActiveRecord provides models with <code>#increment!</code> and
<code>#decrement!</code> instance methods. They'd normally be used to
increment or decrement a counter by one, but they both take optional
second arguments which are the amount by which the counter
(<code>current_disk_usage</code>) should be changed. When the
observer's callback is triggered, the observed object (in this case, an
asset) is passed as an argument to the callback method. Since the
callback is acting on a single object at the time, instead of telling
the user to calculate a sum of all remaining asset's file sizes, we
could just increment or decrement the current disk usage by the file
size of the asset being changed (or in the case of updates, by the
difference between the new and old file sizes). Here's a simple version
of how that would look:

```ruby
class AssetObserver < ActiveRecord::Observer
  def after_save(asset)
    if asset.file_size_changed?
      difference = asset.file_size_change.last - asset.file_size_change.first
      asset.user.increment!(:current_disk_usage, difference)
    end
  end

  def after_destroy(asset)
    asset.user.decrement!(:current_disk_usage, asset.file_size)
  end
end
```

By removing the <code>SELECT SUM</code> call we certainly won't hit the
database as hard for each asset being removed, so perhaps this is a more
correct way of doing things.

As it happens, the application this problem comes from has very light
database use as it is. With only a couple hundred users, each with a few
dozen assets, usually not more than a couple dozen assets total expiring
each week, and reliably long window of inactivity each night (asset
expiration happens once per day), peppering the database with a few
dozen <code>SELECT SUM</code> statements isn't a big deal. The use of
<code>User#recalculate_disk_usage!</code> also has the benefit of
being self-healing: if, somehow, the current disk usage value for a user
were to become corrupted, it would be automatically fixed the next time
<code>#recalculate_disk_usage!</code> was called. If instead of
simply triggering the user's recalculating of disk usage,
<code>AssetObserver</code> becomes responsible for the actual values
being added or subtracted from <code>current_disk_usage</code> there
may be implications for possible data corruption (although that should
be pretty well mitigated by the asset activities being wrapped in a
single database transaction).
