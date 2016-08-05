---
title: How Do You Run Puppet with Ruby Enterprise Edition?
layout: post
tags: puppet
---

**UPDATE 2010-03-11:** Jeff McCune notes in the comments that this issue
is [now documented](http://projects.reductivelabs.com/issues/3363) in
the Puppet issue tracker. It is apparently a bug in Ruby Enterprise
Edition, and it can be worked around by running puppetmaster as a
Passenger/Rack application through Apache, cutting REE out of the SSL
transaction and thereby bypassing the issue.

Sadly, the short answer is, "So far, I don't."

As I've posted before, I install [Ruby Enterprise
Edition](http://www.rubyenterpriseedition.com/) and
[Passenger](http://www.modrails.com/) on my application servers.
Installation is easy and scriptable, which makes it a task I'd prefer to
automate.

I've also recently started evaluating both
[Chef](http://wiki.opscode.com/display/chef/Home) and
[Puppet](http://reductivelabs.com/trac/puppet/wiki) for use in
automating server configuration. Both Chef and Puppet and written in
[Ruby](http://www.ruby-lang.org/) (one of the reasons I picked those two
for evaluation). This post isn't about deciding between the two. They
both have satisfied users and rightly so. They both have pros and cons.
For me, choosing Puppet came down to the fact that I was able to get up
to speed with it more easily than I was with Chef. (In my opinion, Chef
has a lot of potential, but at this stage development is so rapid, I
felt it would be easy for my crack sysadmin team of one to get left
behind).

So eventually I arrived at the thought, if I was going to be using
Puppet to deploy REE to all my servers, it may as well be running on the
Puppet master as well. In fact, why bother with
[Ubuntu's](http://www.ubuntu.com/) Ruby 1.8.6 packages at all?

So I started with two simple virtual machines running 32-bit Ubuntu 8.04
with up-to-date patches -- one to be the Puppet master and one to be the
client. I installed REE 1.8.7-2010.01 as well as the [puppet
0.25.4](http://rubygems.org/gems/puppet) and [facter
1.5.7](http://rubygems.org/gems/facter) gems. I created some Puppet
recipes and got ready to start my first Puppet run. I launched
puppetmasterd on the server, and all appeared to be well. I
then launched puppetd on the client. This is where it
stopped being fun.

As soon as the client connected, puppetmasterd crashed
somewhere in
/opt/ruby-enterprise/lib/ruby/1.8/i686-linux/openssl.so
with <kbd>undefined&nbsp;symbol:&nbsp;sk_x509_num</kbd>. Curiosly, only
puppetmasterd crashed. The instance of puppetd
on the client only complained that the server sent a bum response. I
tried installing REE through dpkg instead of building from
source. Nothing worked, and unfortunately, I couldn't find any mention
of this problem on the web.

As a control, I proceeded to install the OS Ruby packages
(ruby1.8, libruby1.8, ruby1.8-dev
and libopenssl-ruby1.8 among others). I then installed
Rubygems from source, the puppet and facter gems and fired up
puppetmasterd (from the newly-installed puppet gem).
Finally I launched puppetd on the client once more.
Success!

At this point the client was still running Puppet with REE. Only the
Puppet master had the OS Ruby packages installed. So where did I go
wrong? My guess is I should be able to get the Puppet master using REE,
but I'll need to rebuild it with different build flags to make sure
openssl.so has everything it needs. Of course if you
already know what I did wrong, please feel free to leave a comment...

Next time: I'll be writing about the hoops I had to jump through to get
a secondary gem package provider working in Puppet alongside the
existing provider. (Hint: the <code>GEM_HOME</code> environment
variable is set when Puppet installs gems).
