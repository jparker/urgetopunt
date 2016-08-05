---
title: Negative Test Suite Runtimes, or Don't Forget to Call Timecop.return
layout: post
---

**tl;dr** When using [Timecop](https://github.com/jtrupiano/timecop),
always remember to turn it off at the end of the test.

I post this in the hopes that I'm not the only one to make this mistake
and someone else might actually benefit from my stupidity.

It's a sad truth, but in my experience, when googling, googling again
and googling some more for a solution to a problem turns up nary a post
from someone having the same problem, it's usually because
[PEBKAC](https://en.wikipedia.org/wiki/User_error#PEBKAC) (I'm an
idiot). For several days I've been noticing in frustration that the
RSpec suite on one of my applications was periodically reporting
negative runtimes, e.g.,

<samp>
Finished in -537150.87202 seconds
<br>
329 examples, 0 failures
</samp>

This consistently happened when running the entire test suite, but
seemed sporadic when running a subset of the test suite. Adding to my
confusion, at just about the same time that this problem appeared I had
upgraded to RSpec 2.8 which fixed an
[issue](https://github.com/guard/guard-rspec/issues/61) that popped up
when using [Spork](https://github.com/sporkrb/spork). I grudgingly
pushed the matter to the back of my mind since, with the test suite
running sufficiently fast, there were higher priority tasks. But today I
found myself specfically wanting to benchmark the test suite, and these
negative runtimes just wouldn't do. So I poked around deeper.

I generated a fresh Rails application using the same
[template](http://github.com/jparker/rails-templates) I'd used to
generate the offending application. Running the new application's nigh
empty test suite reported accurate (positive) runtimes, so I started
looking for additions/modifications made to
<tt>spec/spec_helper.rb</tt> to see where things diverged. Nothing
seemed significant. I then checked <tt>Gemfile</tt> to see what gems
had been added to the offending application.
[Timecop](https://github.com/jtrupiano/timecop)! Of course, if something
was going to interfere with runtime calculations, freezing Time would
probably do it. I grepped for Timecop in my spec files and found it in
use in only one, but damningly, it was mentioned only once. I was
calling <code>Timecop.freeze</code> from a <code>before</code> block,
but I was not restoring Time by calling <code>Timecop.return</code> from
a corresponding <code>after</code> block.

```ruby
face.send(:palm)
```

I added the missing <code>after</code> block. Runtime reports were
accurate once again. Unicorns! Rainbows! Chocolate milk!

As an aside, if you use [RSpec](http://rspec.info) and
[Spork](https://github.com/sporkrb/spork), and had found yourself adding
the following to your <tt>spec_helper.rb</tt>:

```ruby
Spork.each_run do
  $rspec_start_time = Time.now
end
```

You can remove that kludge after you upgrade to RSpec 2.8. Yay!
