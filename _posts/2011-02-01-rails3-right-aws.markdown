---
title: Rails 3 and RightAws 2.0.0
layout: post
---

If you intend to use
[right_aws](http://github.com/rightscale/right_aws) for interacting
with [S3](http://aws.amazon.com/s3) or other AWS services you will need,
for the time being, to use the git HEAD rather than the gem. At the time
of writing, the most recent gem release, 2.0.0, included some core
extensions which were incompatible with similar extensions added by
ActiveSupport.

I encountered the problem in a Rails 3 application which used
[Devise](http://github.com/plataformatec/devise) for authentication.
After adding right_aws to the Gemfile, my tests suddenly started
failing with the following error:

```
wrong constant name Devise/sessionsController (ActionController::RoutingError)
```

After some poking around I discovered [this
thread](http://groups.google.com/group/plataformatec-devise/browse_thread/thread/d726823ce778597f)
which suggested right_aws was defining a version of
<code>String#camelize</code> which was incompatible with the version
defined by ActiveSupport (ActionController was obviously expecting
<code>Devise::SessionsController</code>). The Rightscale team were aware
of [the issue](https://github.com/rightscale/right_aws/issues/issue/28)
and have already committed a fix, but the new gem has not yet been
released.

Until it is, you can do one of two things:

Update your Gemfile to install right_aws directly from the git repository like
so (the dependency on right_http_connection is required, as the
as-yet-unrelease version of right_aws depends on the as-yet-unreleased version
of right_http_connection):

```ruby
# gem 'right_aws', '~>2.0.0'
gem 'right_aws', :git => 'https://github.com/rightscale/right_aws.git'
gem 'right_http_connection', :git => 'https://github.com/rightscale/right_http_connection.git'
```

Or&hellip; continue using the 2.0.0 gem, but modify
<tt>config/application.rb</tt> as below:

```ruby
require 'rails/all'

# begin workaround
module ActiveSupport::CoreExtensions
end
# end workaround

Bundler.require(:default, Rails.env) if defined?(Bundler)
```

The latter suggestion comes from [a
comment](https://github.com/rightscale/right_aws/issues/issue/28#issue/28/comment/581903)
[Koz](http://www.koziarski.net/) added to the issue discussion. The
<code>ActiveSupport::CoreExtensions</code> module is defined before any
other gems are loaded (before the call to <code>Bundler.require</code>)
which I suppose ends up signaling to right_aws not to define the
conflicting version of <code>String#camelize</code>.

Both of these suggestions worked for me on an application using Rails
3.0.3 (and Devise 1.2.rc) on Ruby 1.9.2p136.
