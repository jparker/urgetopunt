---
layout: post
title: Generating Random Strings in Ruby, Python, and Elixir
tags: [ruby, python, elixir]
---

Whenever I register for a web service, I prefer to use a unique email address.
This makes it easy for me to track who exposed my information to spammers and
makes it easy dump the address when the spam starts rolling in. It also keeps
my user profiles on different services disparate. You may know I go to YouTube
for the [physics videos](https://www.youtube.com/user/minutephysics) and stay
for the [pug videos](https://www.google.com/search?q=pugs%20site%3Ayoutube.com),
but there's no reason to also know about my collection of
[bunny slippers](https://www.amazon.com/s?k=bunny+slippers).

There are trivially easy ways to handle this (Gmail
[supports plus addressing](https://gmail.googleblog.com/2008/03/2-hidden-ways-to-get-more-from-your.html)).
I like to generate completely random addresses. That means generating
random strings, and that's the point of the rest of this article.

I work in [Ruby](https://www.ruby-lang.org) and
[Python](https://www.python.org), and I've been learning
[Elixir](https://elixir-lang.org). When I have a task like this, I like to
explore solutions in each language. It's fun, it's mental exercise, and I
usually end up learning something about each language.

The core component of this task is generating a random string, and that's all
I'm going to detail below. (I'm lazy.)

## The Problem

First, let's describe exaclty what we want to do. 

> Generate a n-character string consisting of the lower-case alphanumeric
> characters `[a-z0-9]`. Characters can be used more than once.

(Depending on how long a random string we are generating, that last requirement
is probably not strictly necessary. We absolutely never want to generate the
same string twice. Our alphabet has 36 characters. It's a combinatorics
problem. If we are generating a four-character string, it's the difference
between a domain of 1,256,640 and 1,679,616 possible strings. Duplication is
unlikely. If we are generating 12-character strings, it's astronomical.
[Without duplicates the domain has almost 400 **quadrillion** possible values;
with duplicates it has almost 5 **quintillion** possible values. The number of
addresses I'm likely to generate in the rest of my life is probably in the low
**hundreds** _at most_. All the same, let's be over-cautious. It will make this
post that much longer.)

## Ruby

First, the Ruby solution.

```ruby
alphabet = (?a..?z).to_a + (?0..?9).to_a
length = 12

alphabet.sample(length).join # => "a5i9h6c3pln1"
```

That was pretty easy. It's good enough, frankly, but it doesn't quite meet the
specification. Can you spot the problem? `Array#sample` doesn't take duplicates
within a single call. If I want duplicates, I need to take multiple samples.

```ruby
length.times.map { alphabet.sample }.join # => "z7hddxpejup7"
```

Done. It's not quite as pretty, but it's still pretty easy to follow.

## Python

Now let's do the same thing in Python.

```python
import random
import string

alphabet = string.ascii_lowercase + string.digits
length = 12

str.join('', random.sample(alphabet, k=length)) # => '7utd39nsbvzg'
```

That was also pretty easy. There's a little extra boilerplate required
importing modules, but `string.ascii_lowercae` and `string.digits` are nice.
But, wait. It's get the same problem as our first Ruby solution:
`random.sample` doesn't produce duplicates. I can do better.

```python
str.join('', random.choices(alphabet, k=length)) # => 'hs8j3mr4lm4e'
```

Aces. The only difference is using `random.choices` instead of `random.sample`.
I actually like that. It's more descriptive of what I am doing. I don't want
a sample from the string; I want a combination.

## Elixir

Finally, let's try it in Elixir. (I'm still learning Elixir. You've been
warned.)

```elixir
alphabet = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)
length = 12

Enum.take_random(alphabet, length) # => 'g5qe0dl3b1kp'
```

Once again, pretty easy, but wait a minute. How is this possible? I've made the
same mistake again! `Enum.take_random/2` doesn't repeat characters. (Seriously?
It's almost like I'm doing this on purpose.) I can fix this.

```elixir
Enum.map(1..length, fn _ -> Enum.random(alphabet) end) # => '68s2n4wmj24p'
```

Now I'm getting it. Similar to Ruby, I need to take multiple samples in order
to allow duplication.

For extra credit, I'm going to explore one other option.


```elixir
for _ <- 1..length, into: "", do: << Enum.random(alphabet) >> # => "kk27cersvez9"
```

This uses a list comprehension to take multiple samples again. It also has a
subtly different return value. Instead of a charlist (a list of code points),
it return a string (a UTF-8 encoded binary). For my purposes, either of these
solutions works because the return value ends up being interpolated into a
string. (I'm generating email addresses. I need a username and a domain, so
eventually the script ends up doing something like this:

```elixir
"#{username}@#{domain}" # => "tiaa2ubspzy3@example.com"
```

## Fin

So there you have it. I make no claims about any of these solutions being the
most idiomatic way to perform this task in their respective languages, but
these solutions do work. Let's get a taco.
