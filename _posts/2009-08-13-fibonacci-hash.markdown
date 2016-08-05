---
title: Fibonacci Sequence in a Hash
layout: post
tags: ruby
---

Being able to instantiate a Hash that calculates Fibonacci numbers is
just another reason I like Ruby...

```ruby
fib = Hash.new {|h,n| h[n] = h[n-1] + h[n-2] }
fib[0] = 0
fib[1] = 1

fib[11]  # => 89
fib[12]  # => 144
fib[101] # => 573147844013817084101
```

It may not be as compact as what Perl 6 promises, but it's a lot more
legible.

```ruby
# Based on Larry's and Damian's Perl6 talk at OSCON 2009
@fib = 0,1...&[+]
```
