---
title: Using RVM from Launchd Scripts on OS X
layout: post
categories: rvm osx
---

I use [Launchd](/osx/2009/08/30/launchd-for-cron-jobs.html) to run some
scripts on a Mac with cron-like regularity. (OS X provides cron, but
Launchd is apparently the *preferred* approach.) Many of those scripts
are written in [Ruby](http://www.ruby-lang.org/), and I'm trying to
migrate them to Ruby 1.9.2 as part of my overall migration. OS X has
Ruby 1.8.7p174 installed by default. I use
[RVM](http://rvm.beginrescueend.com) to manage other versions including
1.9.2. The scripts are executable and start with a "magic shebang" line
of <code>#!/usr/bin/env ruby</code>. Run from my shell, where RVM is
configured and 1.9.2 is my default interpreter, everything just works.
When run from Launchd, however, RVM is not configured. The system ruby
is used instead, and as I don't generally install any gems for the
system Ruby, and since some of the scripts aren't even compatible with
Ruby 1.8, things blow up.

To work around this, I installed a wrapper as
<tt>$HOME/bin/_rvmruby</tt> that sets up RVM and then execs ruby:

```bash
#!/bin/sh
# usage: _rvmruby <ruby version> [ruby arguments]

if [[ -s ~/.rvm/scripts/rvm ]]; then
  . ~/.rvm/scripts/rvm
fi

ruby_version=$1; shift
rvm $ruby_version
exec ruby "$@"
```

It requires you to specify the version of Ruby you want. You can even
include the gemset if you want. A little extra logic could get it to ue
a sensible default, but I'm too lazy.

Next I modify the plist file for the "cron" job to use the wrapper:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>com.example.wozziegoggle</string>
        <key>ProgramArguments</key>
        <array>
                <string>PATH_TO_WRAPPER/_rvmruby</string>
                <string>RUBY_VERSION</string>
                <string>PATH_TO_RUBY_SCRIPT</string>
        </array>
        <key>StartCalendarInterval</key>
        <dict>
                <key>Hour</key>
                <integer>6</integer>
                <key>Minute</key>
                <integer>0</integer>
        </dict>
</dict>
</plist>
```

The array of strings provided to <tt>ProgramArguments</tt> is the
command and arguments you want Launchd to to run. Obviously replace
<tt>PATH_TO_WRAPPER</tt>, <tt>RUBY_VERSION</tt> and
<tt>PATH_TO_RUBY_SCRIPT</tt> with the actual path to
<tt>_rvmruby</tt>, the version of Ruby you want to use and the path
to the script you want to run, respectively.
