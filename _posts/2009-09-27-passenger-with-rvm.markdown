---
title: Using Passenger with rvm
layout: post
---

**UPDATE 2010-04-03:** docgecko notes in the comments below that more
recent versions of RVM now provide the <code>passenger_ruby</code>
command for using RVM-installed versions of Ruby with Phusion Passenger.
This article has been updated with the newer instructions, but [RVM's
Passenger
instructions](http://rvm.beginrescueend.com/integration/passenger/) are
more likely to be up to date. Thanks for the update, docgecko.

I've recently starting using [Ruby Version
Manager](http://rvm.beginrescueend.com/) (aka rvm) to manage multiple
ruby versions on my workstation. So far I'm quite pleased with the ease
of use. (My only gripe so far is that the <code>rvm</code> command is
uncomfortably close to <code>rm</code> -- it's only a matter of time
before I shoot myself in the foot).

There is one gotcha. In production I use [Phusion
Passenger](http://www.modrails.com/) in conjunction with [Ruby
Enterprise Edition](http://www.rubyenterpriseedition.com/). I would like
to use the same environment in development. However, when installing the
passenger gem into an rvm-managed ruby installation, the path to the
ruby binary (which you need to plug somewhere into your Apache config)
will not work. It will have an incorrect gem path, and in my case, that
resulted in passenger failing to spin up because it was unable to load
the fastthread gem.

```
/Users/jparker/.rvm/ruby-enterprise-1.8.6-20090610/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:31:in `gem_original_require': no such file to load -- fastthread (LoadError)
        from /Users/jparker/.rvm/ruby-enterprise-1.8.6-20090610/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:31:in `require'
        from /Users/jparker/.rvm/gems/ruby-enterprise/1.8.6/gems/passenger-2.2.5/lib/phusion_passenger/utils.rb:28
        from /Users/jparker/.rvm/gems/ruby-enterprise/1.8.6/gems/passenger-2.2.5/bin/passenger-spawn-server:53:in `require'
        from /Users/jparker/.rvm/gems/ruby-enterprise/1.8.6/gems/passenger-2.2.5/bin/passenger-spawn-server:53
```

The solution is [very clearly
printed](http://rvm.beginrescueend.com/integration/passenger/) on the
rvm web site. Instead of passing the path to the actual ruby binary to
the <code>PassengerRuby</code> directive, pass in the
<code>RVM_ROOT/bin/passenger_ruby</code> (replacing RVM_PATH with the
root of your rvm installation \[usually <code>$HOME/.rvm</code>\]).

```
# Don't do this
PassengerRuby /Users/jparker/.rvm/ruby-enterprise-1.8.6-20090610/bin/ruby

# Do this instead
PassengerRuby /Users/jparker/.rvm/bin/passenger_ruby
```

The latter is a shell script which execs the actual ruby binary after
setting an appropriate <code>GEM_HOME</code> and <code>GEM_PATH</code>
(among other things).
