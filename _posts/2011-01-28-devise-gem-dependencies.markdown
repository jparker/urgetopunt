---
title: Gem Dependencies for Devise
layout: post
tags: devise
---

I recently worked with [devise](https://github.com/plataformatec/devise)
in a Rails application for the first time. Using Rails 3.0.3, Bundler
1.0.9 either Devise 1.1.5 or 1.2.RC I found I had to manually add
dependencies for Hpricot and Ruby\_parser to my Gemfile in order to run
the <code>devise:views</code> generator. Without those to gems
explicitly declared as dependencies, running the generator produced
empty views under <code>RAILS\_ROOT/app/views/devise</code> and yielded
the following errors:

```
$ rails g devise:views
Required dependency hpricot not found!
Run "gem install hpricot" to get it.
…
```

And then after adding hpricot to the Gemfile:

```
$ rails g devise:views
Required dependency ruby_parser not found!
    Run "gem install ruby_parser" to get it.
…
```

As I wasn't relying on those gems for anything else in the application,
I only added them to the <tt>development</tt> group:

```ruby
# Gemfile
group :development do
  gem 'hpricot'
  gem 'ruby_parser'
end
```

With those dependencies declared running the generator works as
expected.
