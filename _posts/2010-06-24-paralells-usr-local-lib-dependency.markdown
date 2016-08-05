---
title: Parallels Desktop and the /usr/local/lib dependency
layout: post
---

**UPDATE 2010-06-30:** I added a missing backslash (<code>\</code>) to
escape a space in the pathname given in the <code>ln -s</code>
invocation at the end of the article.

If you use [Parallels Desktop](http://www.parallels.com/) on a Mac, be
aware that it may install dependencies in <code>/usr/local/lib</code>.

After a couple months of not needing access to any virtual machines, I
recently tried to fire up Parallels on my Mac only to find that it would
crash immediately. I checked Console.app for possible error messages and
discovered the following single message:

<div class="code">
    ([0x0-0x5ba5ba].com.parallels.desktop.console[84395]) Exited with exit code: 9

</div>
It was repeated every time I tried to launch Parallels. I started
searching the mighty intertubes for a clue, and ran across a [lengthy
thread](http://forum.parallels.com/printthread.php?t=31231) on the
Parallels Forum about the same problem with Parallels 3.0 (I'm using
4.0). Down towards the bottom of the first page user "wa6vvv" mentions
that Parallels may create a symlink for <code>libprl_sdk.dylib</code>
in <code>/usr/local/lib</code>. I spun up a backup and sure enough
<code>libprl_sdk.dylib</code> was a symlink to a file buried deep under
<code>/Library/Parallels/Parallels Service.app</code>.

If you don't have backups (but you really, *really* should) the symlink
is still easy enough to restore via the command line:

```
$ ln -s /Library/Parallels/Parallels\ Service.app/Contents/Frameworks/ParallelsVirtualizationSDK.framework/Versions/Current/Libraries/libprl_sdk.dylib /usr/local/lib/libprl_sdk.dylib
```

(Note that I replaced "4.0" with "Current" in the command above. That
should make the command portable if you're having the same problem but
with a different version of Parallels.)

After restoring the symlink Parallels is once again working. All is
right with the world.
