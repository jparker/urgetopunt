---
layout: post
title: Hidden Files and the Finder
---

If you are working on a Mac and have an unfortunate run-in with a
mistyped <code>rm -r</code> command, you may find yourself in need of
restoring files, including those elusive dot files which don't show up
in the OS X Finder by default. If you've been using [Time
Machine](http://www.apple.com/macosx/features/timemachine.html) to
backup your data, doing restores is easy, but before you can restore
hidden files, you have to tell the Finder to display them.

The following commands will do just that:

```
$ defaults write com.apple.finder AppleShowAllFiles TRUE
$ killall Finder
```

After the Finder has restarted, you can go into Time Machine and restore
hidden files to your heart's content. When you're done, if you want to
turn display of hidden files back off (they do clutter up Finder windows
and the Desktop), the reverse is intuitive:

```
$ defaults write com.apple.finder AppleShowAllFiles FALSE
$ killall Finder
```

Voil&agrave;.
