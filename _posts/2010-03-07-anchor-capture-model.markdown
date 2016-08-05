---
title: Pondering Pickled Patterns
layout: post
categories: cucumber
---

For me [Pickle](http://github.com/ianwhite/pickle) is what made
[Cucumber](http://cuke.info/) make sense to me for integration testing.
I had a hard time coping with the idea of spending so much time going
between nearly English features and huge swaths of regular expressions.
Pickle cuts down on a lot of the regular expression drudgery by defining
some generic steps for working with models. If you haven't tried Pickle
out yet, I highly recommend it. [Railscast
186](http://railscasts.com/episodes/186-pickle-with-cucumber) gives a
great overview.

In addition to the generic step definitions Pickle provides, it also
gives you access to the powerful regular expressions that drive those
steps. I just spent some time hung up on one of those regexps,
<code>capture_model</code>.

In the feature I was creating a labeled account and then visiting the
users page for that account:

```
Given an account: "spectre" exists
When I go to the users page for the account: "spectre"
```

Then I was using <code>capture_model</code> in a pattern in
<code>features/support/paths.rb</code> like so:

```ruby
case page_name
# ...
when /the users page for #{capture_model}/
  account = model($1)
  users_path(:subdomain => account.subdomain)
# ...
end
```

Unfortunately, every time I ran the feature, <code>#model</code> would
return <code>nil</code>. After banging my head into this for a while I
finally determined that <code>#capture_model</code> was capturing an
empty pattern, so I was passing <code>""</code> to <code>#model</code>.

I printed out the the regexp returned by <code>#capture_model</code>
to see what was going on (brace yourself):

```re
/((?:(?:)|(?:(?:a|an|another|the|that) )?(?:(?:(?:(?:first|last|(?:\d+(?:st|nd|rd|th))) )?(?:account|user))|(?:(?:account|user)(?::? \"(?:[^\\"]|\.)*\")))))/
```

The regular expression is built up programmatically at runtime based on
the models which currently exist in your application. (As you can see
above, in the application I was working on I only had Account and User
models defined). The regexp is long and looks a little like Lisp code
that's been tweaking, but if you look closely you'll probably come to
realize (faster than I did) that it will happily match an empty string.
In fact, in the pattern I was using in <code>paths.rb</code>
<code>#capture_model</code> was matching an empty string and the rest
of the line was being thrown away. Unfortunately that part -- <code>the
account: "spectre"</code> -- was the most important part...

Realizing where I was going wrong I anchored my pattern to the end of
the line:

```ruby
when /the users page for #{capture_model}$/
```

Woo! Now the line only matches when everything between "the users page
for " and the end of the line can be matched by
<code>#capture_model</code>. With this addition, the regexp captured
the model label <code>account: "spectre"</code> and <code>#model</code>
finally returned the record. *Allons-y!*

The moral of the story: anchor your patterns whenever possible. It's
generally good practice if only to make sure you acting on the correct
data.
