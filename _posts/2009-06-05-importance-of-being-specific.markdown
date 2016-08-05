---
title: The Importance of Being Specific
layout: post
---

Do not do this in your <code>.autotest</code> file.

```ruby
Autotest.add_hook :initialize do |at|
  at.add_exception 'vendor'
  nil
end
```

Instead, be specific.

```ruby
Autotest.add_hook :initialize do |at|
  at.add_exception %r{^vendor/}
  nil
end
```

One of the benefits of
[autotest](http://www.zenspider.com/ZSS/Products/ZenTest/) is that it
can save you time. It's not saving you time when you spend 15 minutes
trying to figure out why it isn't running any of the tests from
<tt>vendor_controller_test.rb</tt>. Be good to your tools, and
they will be good to you. Tell them **exactly** what it is you'd like to
do, and they will be happy to oblige. Read the
[documentation](http://zentest.rubyforge.org/ZenTest) about a feature
when you use it -- then maybe you'll realize that a
[method](http://zentest.rubyforge.org/ZenTest/Autotest.html#M000043)
actually expects a Regexp as an argument.

If you don't read the documentation, you risk being a tool... Like me.
