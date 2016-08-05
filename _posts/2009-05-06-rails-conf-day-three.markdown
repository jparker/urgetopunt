---
title: RailsConf Day Three
layout: post
---

My early morning session was [Using metric\_fu to Make Your Rails Code
Better](http://en.oreilly.com/rails2009/public/schedule/detail/7935)
with Jake Scruggs. Aside from [rcov](http://eigenclass.org/hiki.rb?rcov)
and the stats rake task in Rails I haven't yet spent much time studying
code metrics. Jake touched on a number of different tools available
today, each of which looked quite interesting and each of which is (or
can be) used within [metric\_fu](http://metric-fu.rubyforge.org/). The
metric\_fu rake tasks generate reports which can provide useful
information on where you might need to focus your refactoring efforts by
identifying potential problem spots like overly complex methods and
repetitious code. I've seen the announcements about metric\_fu, but
hadn't taken a close look at it until this session. I find I'm eager to
try it out but dreading what I will discover.

In the late morning I attended [Are You Taking Things Too
Far?](http://en.oreilly.com/rails2009/public/schedule/detail/7591) with
Michael Koziarski. The basic message of this session is pretty easy to
extract from the title, and it's one that I've heard in several sessions
this week -- don't be overly dogmatic. Rails has introduced plenty of
conventions that, in general, make our jobs easier, but it's important
to remember that, sometimes, the conventional way may not be the best
way. Sometimes fiercely sticking to convention can mean writing more
code than you really need that requires more maintenance than you have
time for and which expresses your intent less obviously than a simpler,
less conventional approach. Conventions are good, but sometimes you need
to be willing to break with them.

Early afternoon session probably would have been interesting, but I had
to catch up with work (coffee in Las Vegas isn't cheap).

For the mid afternoon session I attended [Working Effectively with
Legacy Rails
Code](http://en.oreilly.com/rails2009/public/schedule/detail/7847) with
Pat Maddox and BJ Clark. This was a particularly appealing talk, as it's
a challenge I've spent a lot of time wrestling recently -- taming Rails
code I wrote before I'd learned many of Rails most helpful features. One
of their suggestions was to keep an eye out for occasions where complex,
semi-redundant code can be abstracted into a "mini framework" that you
can mix-in as needed, and, as a corollary, keep an eye out for occasions
where convoluted code may be unnecessry because Rails already provides a
facility to do what needs to be done. They also announced their [new
blog](http://refactorsquad.com/).

Late afternoon session [%w(map reduce).first -- A Tale About Rabbits,
Latency and Slim
Crontabs](http://en.oreilly.com/rails2009/public/schedule/detail/8519)
with Paolo Negri. Paulo gave an interesting overview of how and why to
use [RabbitMQ](http://www.rabbitmq.com/) from Ruby. This is one of those
times where the topic is fascinating, but I really don't have any
immediate application for it.

The [evening
keynote](http://en.oreilly.com/rails2009/public/schedule/detail/8482)
with Bob Martin was a particular treat and one of the most entertaining
I've attended in years. The value of testing was the core of the talk.
He presented the three rules of true test-driven development:

1.  You are not allowed to write a single line of production code until
    you have written a failing test.
2.  You are not allowed to write a single line of additional test code
    once you have a failing test.
3.  You are not allowed to write a single line of production code beyond
    what is needed to make the failing test pass.

Following those rules to the letter requires extraordinary discipline,
but he asked us to think what our development world would be like if we
followed through. Tests eliminate fear and risk -- if you have the
tests, you can refactor the production code with confidence. Ruby (and
Rails) can spare itself the fate of Smalltalk (which he said basically
died of hubris) by three things:

1.  Professional discipline -- specifically, writing well-tested code.
2.  Professional humility -- not encouraging and adversarial
    relationship with other languages.
3.  Professional responsibility -- not shying away from fixing dirty
    coding problems when they are discovered.

"Uncle Bob" is a marvelous presenter and showman in general, but one
comment near the end struck me as particularly funny:

> \[When Smalltalk died, its programmers\] had to start writing Java,
> and it nearly killed them.
