---
title: RailsConf Day One
layout: post
---

The tutorial day for [RailsConf 2009](http://www.railsconf.com/) has
drawn to a close. I spent the morning in [Running the Show:
Configuration Management with
Chef](http://en.oreilly.com/rails2009/public/schedule/detail/7763) by
Edd Dumbill. The first half of the tutorial was a bit awkward when the
live demo failed to get off the ground. While I don't feel I walked away
with any concrete training, I did come away with enough appreciation of
[Chef](http://wiki.opscode.com/display/chef/Home) that I'm looking
forward to learning and using it to rein in the increasing number of
nearly identical systems I find myself managing.

In the afternoon I attended Joe O'Brien's and Jim Weirich's [Testing,
Design and
Refactoring](http://en.oreilly.com/rails2009/public/schedule/detail/7786).
The first half of the tutorial consisted of presentation by both Jim and
Joe. Part of Jim's talk included the material from his "Writing Modular
Code" talk from [Scotland on Rails](http://scotlandonrails.com/). Joe's
portion covered some of the general methods of
[refactoring](http://refactoring.com/) and why you might use them. One
concept that struck a chord with me was the concept (or goal) of
simplicity. Simple code has the following characteristics:

1.  Passes tests, i.e., the code works
2.  No duplication
3.  Clearly expresses intent
4.  Minimal number of classes and methods

And those characteristics are in order of importance. If the code
doesn't work, it doesn't matter whether or not it's clear. (I'm a little
fuzzy about the order of duplication and clarity in that list though. If
eliminating duplication results in loss of clarity, that may not be a
net win.)
