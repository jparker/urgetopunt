---
title: Useful Objects in the Rails Console
layout: post
categories: rails
---

The Rails console is a wonderful place to be if you need to feel things
out in a Rails application. Playing with your models in the console is
easy. They are all just *there*. But two non-model functions I
frequently find myself want to play with are view helpers and route
helpers. They are there too, but they are abstracted behind objects
whose name I'm constantly forgetting. I'm documenting them here in the
hopes that it'll help me remember and or make their names easy to find
the next time I inevitably forget.

Route helpers are available on the <code>app</code> object:

```
$ rails c
Loading development environment (Rails 3.0.3)
ruby-1.9.2-p136 :001 > app.class
 => ActionDispatch::Integration::Session
ruby-1.9.2-p136 :002 > app.root_path
 => "/"
ruby-1.9.2-p136 :003 > app.root_url
 => "http://www.example.com/" 
ruby-1.9.2-p136 :004 > app.new_user_session_path
 => "/users/sign_in"
```

View helpers are available on the <code>helper</code> object:

```
$ rails c
Loading development environment (Rails 3.0.3)
ruby-1.9.2-p136 :001 > helper.class
 => ActionView::Base 
ruby-1.9.2-p136 :002 > helper.link_to 'Sign out', '/sign_out'
 => "<a href="/sign_out">Sign out</a>" 
ruby-1.9.2-p136 :003 > helper.time_ago_in_words 42.days.ago
 => "about 1 month" 
ruby-1.9.2-p136 :004 > helper.number_to_human_size 42.megabytes
 => "42 MB"
```

These helpers go back at least as far back as Rails 2.1.
