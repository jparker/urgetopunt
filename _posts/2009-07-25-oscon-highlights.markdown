---
title: OSCON Highlights
layout: post
tags: oscon
---

OSCON is over. While there were a number of interesting sessions, the
following two struck me as particularly interesting.

### [7 Principles of API Design](http://en.oreilly.com/oscon2009/public/schedule/detail/8062)

[Damian
Conway's](http://en.oreilly.com/oscon2009/public/schedule/speaker/4710)
API design tutorial used Perl for the examples, but the ideas can
reasonably be applied to most other languages as well. The talk was
organized around Arthur C. Clark's third [law of
prediction](http://en.wikipedia.org/wiki/Clarke's_three_laws):

> Any sufficiently advanced technology is indistinguishable from magic.

The idea is to develop software modules that are so clever they can be
useful with a minimal interface or even no interface at all. A good
example of this is Perl's <span
style="text-align:left;">[code&gt;strict</code>](http://perldoc.perl.org/strict.html)</span>
pragma which does everything expected just by adding <code>use
strict</code>.

The seven principles follow:

1.  **Do one thing well.** Keep methods small and tightly focused.
2.  **Design by coding.** Designing APIs around expected usage leads to
    intuitive, easy-to-use APIs.
3.  **Evolve by subtraction.** Squash needless complexity whenever
    you can. Find better defaults.
4.  **Declarative beats imperative.** Let users say "what" rather
    than "how".
5.  **Preserve the metadata.** If a module knows something useful at one
    point, it should remember that information later on.
6.  **Leverage the familiar.** The easiest interface to understand and
    use is one you are already using.
7.  **Best code is no code at all.** Modules that can be used with very
    little conscious effort can be a delight to use.

### [The HTML 5 Experiment](http://en.oreilly.com/oscon2009/public/schedule/detail/8856)

[Bruce
Lawson](http://en.oreilly.com/oscon2009/public/schedule/speaker/49932)
discussed the future with HTML 5. All of the major browser players --
Microsoft (IE), Mozilla (Firefox), Apple (Safari), Opera (Opera) and
Google (Chrome) -- support some subset of the features of HTML 5
already, so you can start playing with it today. HTML 5 is (mostly) a
superset of HTML 4 which means HTML 5 pages will usually degrade with
some semblance of grace. Because it is so common for page structures to
include distinct areas for headers (not to be confused with
<code>HEAD</code>), footers and navigation menus, HTML 5 has
<code>header</code>, <code>footer</code> and <code>nav</code> tags.
Unlike a <code>div</code> with a specific id attribute, these tags have
semantic meaning that can be used by page readers. Forms in HTML 5 have
a whole slough of features that previously could only by achieved with a
lot of Javascript. Among these features are common validations (required
fields, valid email formats, valid numbers, etc.), an
<code>autofocus</code> attribute and a calendar picker.
