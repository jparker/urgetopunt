---
layout: post
title: Connascence and Software Development
---

This morning at [Scotland on Rails](http://scotlandonrails.com/) [Jim
Weirich](http://onestepback.org/) gave a fascinating talk covering a
software development pattern called *connascence*. His slides are
[available on
Github](http://github.com/jimweirich/presentation_connascence).

Connascence describes a kind of coupling within your code. Jim covered
several forms:

-   Connascence of Name (CoN)
-   Connascence of Position (CoP)
-   Connascence of Meaning (CoM)
-   Contranascence (CN)
-   Connascence of Algorithm (CoA)
-   Connascence of Timing (CoT)

In addition to the various forms of connascence he described two rules
for dealing with connascence in your software.

1.  Rule of Locality -- As the distance between software elements
    increases, use weaker forms of connascence.
2.  Rule of Degree -- Convert high degrees of connascence into weaker
    forms of connascence.

His slides have good examples of each of these forms, but consider a
quick example. If a method has several -- say 4 or 5 -- positional
parameters, it has a high degree of connascence of position. Over time,
if parameters have to be added, removed or just reordered, this code
will prove to be brittle as any code that calls that method would also
have to be updated. The situation can be improved by replacing those
positional parameters with a single hash parameter. The hash keys
introduce connascence of name but eliminate concern over position,
decoupling the method defintion somewhat from the code that calls it.

I haven't yet attended a talk by Jim that wasn't enlightening (I got
started with Ruby because of his "Ruby for Java Programmers" talk at
OSCON 2005), and this talk was no different. Seeing these patterns
isolated and explained helps me with the ongoing goal of achieving
greater discipline as a software developer. Thanks, Jim.
