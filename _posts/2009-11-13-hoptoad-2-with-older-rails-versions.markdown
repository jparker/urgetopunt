---
title: Hoptoad Notifier v2 and Older Versions of Rails
layout: post
---

**UPDATE 2015-02-23:** Hoptoad is now [Airbrake](http://airbrake.io).

**UPDATE 2009-11-18:** It appears the issue [has been
fixed](http://help.hoptoadapp.com/discussions/problems/401-nomethoderror-undefined-method-to_hash-for-cgisession0x2b73dc4b9c60)
(though I haven't had a chance to try it out myself).

(I'm documenting this because I had a hard time googling it.)

With a [new Hoptoad
API](http://robots.thoughtbot.com/post/238327967/new-hoptoad-api-and-development-error-tracking)
around the corner comes a new version of the
[hoptoad_notifier](http://github.com/thoughtbot/hoptoad_notifier)
plugin. I've been using [Hoptoad](http://hoptoadapp.com/) for about a
year, and I've been generally pleased with it. Though I have no
particular plans for taking advantage of the API in the foreseeable
future, I figured it would be a good idea to start upgrading from 1.2.x
to 2.0.x in case there are any gotchas. If you are using Hoptoad on an
application that is running a pre-2.3 version of Rails, there are
gotchas.

Among the data the notifier sends to Hoptoad when an exception occurs is
the contents of the user's session. Older versions of the notifier tried
to convert the session object to a Hash using
<code>session#to_hash</code>, but if the session object didn't respond
to <code>#to_hash</code> (and it doesn't in Rails 2.2 and earlier) it
resorted to sending the <code>@data</code> instance variable contained
within the session object. In 1.2.x versions of the notifier you can see
this going on in <code>lib/hoptoad_notifier.rb</code>.
In the newer version of the notifier, this logic has been moved to <code>lib/hoptoad_notifier/catcher.rb</code>.
It calls <code>session#to_hash</code> blindly which raises
<code>NoMethodError</code> in Rails 2.2 and earlier.

After spending too much time figuring out what was going on, I stumbled
upon [a
discussion](http://help.hoptoadapp.com/discussions/problems/401-nomethoderror-undefined-method-to_hash-for-cgisession0x2b73dc4b9c60)
about this very problem. As of this writing it appears the developers
know what the problem is and are working to resolve it. Until then, hold
off on version 2 of the hoptoad\_notifier plugin if you are on Rails 2.2
or earlier.
