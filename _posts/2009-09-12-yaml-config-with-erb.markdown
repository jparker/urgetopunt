---
title: Using ERB in YAML Configuration File
layout: post
tags: rails
---

A while back in [Railscast
\#85](http://railscasts.com/episodes/85-yaml-configuration-file) Ryan
Bates demonstrated how to add a YAML-based configuration file to a Rails
application. You start with the configuration file -- say
<code>RAILS_ROOT/config/app_config.yml</code> -- containing your
configuration data:

```yaml
# config/app_config.yml
development:
  key1: development value 1
test:
  key1: test value 1
production:
  key1: production value 1
```

And then you load the file from an initializer -- say
<code>RAILS_ROOT/config/initializer/load_config.rb</code> --
containing the following:

```ruby
# config/initializers/load_config.rb
APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
```

And from then on a Hash named <code>APP_CONFIG</code> will be available
throughout your application containing the configuration specific to the
environment in which your application is running, i.e., development,
test or production.

But what if you want to dynamically configure one or more values in your
configuration file? Other YAML files loaded by Rails such as fixture
files or <code>database.yml</code> are processed through ERB before
being loaded. Wouldn't it be nice to be able to do the same in your
application configuration file?

```yaml
# config/app_config.yml
development:
  key1: <%= # ruby code ... %>
test:
  key1: <%= # ruby code ... %>
production:
  key1: <%= # ruby code ... %>
```

As it is Rails will not process those ERB snippets, but you can change
that with one small change to your initializer:

```ruby
# config/initializers/load_config.rb
APP_CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/app_config.yml")).result)[Rails.env]
```

Now, instead of loading the file directly, YAML loads the string
returned by <code>ERB\#result</code> which will contain the contents of
the <code>app_config.yml</code> after the ERB snippets have been
evaluated.
