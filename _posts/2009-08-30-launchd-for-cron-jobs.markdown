---
title: Launchd for Cron Jobs
layout: post
categories: osx
---

Although cron is nominally supported on OS X, the preferred alternative
seems to be [launchd](http://developer.apple.com/MacOsX/launchd.html).
It is often used to run jobs at startup (much like an init script), but
it also has configuration options to produce cron-like scheduling. For
more information, check out the <code>launchd(8)</code> and
<code>launchd.plist(5)</code> man page, and pay particular attention to
the <code>StartCalendarInterval</code> attribute.

This is a plist file I'm using to get launchd to periodically run a
[script](http://github.com/jparker/dotfiles/blob/master/bin/backup.rb)
which pulls down copies of database dumps from remote servers and then
uploads them to [S3](http://aws.amazon.com/s3/):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.urgetopunt.backup</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/ruby</string>
    <string>/Users/jparker/bin/backup.rb</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>0</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
</dict>
</plist>
```

The file lives in
<code>$HOME/Library/LaunchAgents/com.urgetopunt.backup.plist</code>,
and it was loaded into launchd by running the following command (no root
privileges necessary):

<kbd>$ launchctl load -w $HOME/Library/LaunchAgents/com.urgetopunt.backup.plist</kbd>

Crontabs are still, in my opinion, much easier to deal with than XML
documents, but launchd does offer certain advantages for desktop
platforms. If my Mac is asleep when a cron job is scheduled to run, that
run is missed. If launchd determines that a run was missed because the
system was asleep, it runs the job when the system wakes up. If multiple
consecutive runs are missed, it only runs the job once to get caught up.
