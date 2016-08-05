---
title: Capistrano, Ruby 1.9 and SSH Gateways — Resolved!
layout: post
categories: capistrano
---

A few months ago [I
posted](/capistrano/2011/01/16/capistrano-ruby19-ssh-gateway.html) about
inconsistent performance when running
[capistrano](https://github.com/capistrano/capistrano/wiki) under [Ruby
1.9](http://www.ruby-lang.org) when SSH traffic was routed through a
gateway host. This problem appears to have been solved in a [recent
commit](https://github.com/net-ssh/net-ssh-gateway/commit/b448fe7da9ade93b798d812fb0c89d6fd2f7659c)
to net-ssh-gateway (kudos to Mat Trudel).

I discovered this when installing capistrano 2.6.0. Reading through the
updates I saw some promising references to a thread deadlocking issue
the existed under Ruby 1.9. After installing the new version of
capistrano (and net-ssh-gateway) I re-ran the tests described in my
[previous post](/capistrano/2011/01/16/capistrano-ruby19-ssh-gateway.html), and
sure enough, the improvement is outstanding!

{:.table.table-bordered.table-hover.table-striped}
||real|user|sys|
|min|2.75s|0.78s|0.22s|
|max|7.17s|1.51s|0.43s|
|mean|3.76s|0.91s|0.26s|
|stddev|1.22s|0.14s|0.04s|
|median|3.33s|0.86s|0.24s|

([Full runtime data](https://gist.github.com/958172).)

Congratulations and my gratitude are due to the team of people presently
maintaining capistrano, net-ssh-gateway, etc.
