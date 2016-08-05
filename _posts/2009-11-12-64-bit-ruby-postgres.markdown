---
title: "Snow Leopard, Ruby & PostgreSQL: A Cautionary Tale"
layout: post
---

My development machine is a Mac running Snow Leopard in 64-bit mode with
[PostgreSQL](http://www.postgresql.org/) (via
[MacPorts](http://www.macports.org/)) and [Ruby Enterprise
Edition](http://www.rubyenterpriseedition.com/) (via [Ruby Version
Manager](http://rvm.beginrescueend.com/)). I recently upgraded my REE
installation to version 1.8.7-2009.10 only to discover that the ruby-pg
gem was no longer able to establish connections to PostgreSQL. In the
error message I saw the words <code>pg-0.8.0/lib/pg.bundle: no matching
architecture</code>, performed a jaunty shrug (I was in a cheery mood)
and charged merrily into the task of reinstalling the ruby-pg gem in
64-bit mode.

(At this point a clever person would have paused to consider the fact
that neither PostgreSQL nor the ruby-pg gem had changed at this point. A
clever person would have taken a moment to double check the way the new
version of REE was installed before wasting close to an hour that could
have been better spent in the pub. I am not a clever person.)

I set about reinstalling the ruby-pg gem with no configuration options
only to meet with verbose failure which began with:

```
In file included from compat.c:16:
compat.h:38:2: error: #error PostgreSQL client version too old, requires 7.3 or later.
In file included from compat.c:16:
compat.h:69: error: conflicting types for ‘PQconnectionNeedsPassword’
/opt/local/include/postgresql83/libpq-fe.h:266: error: previous declaration of ‘PQconnectionNeedsPassword’ was here
compat.h:70: error: conflicting types for ‘PQconnectionUsedPassword’
/opt/local/include/postgresql83/libpq-fe.h:267: error: previous declaration of ‘PQconnectionUsedPassword’ was here
```

I tried again with <code>ARCHFLAGS="-arch x86_64"</code> but to no
avail. I tried <code>ARCHFLAGS="-arch i386"</code>. Skunked again.
Version to old? How could that be. The only version of PostgreSQL I'd
ever installed on this machine was 8.3.8. I verified the installed
version and that <code>pg_config</code> was in my path:

```sh
$ port installed postgresql*
The following ports are currently installed:
postgresql83 @8.3.8_0 (active)
postgresql83-server @8.3.8_0 (active)
$ pg_config | grep VERSION
VERSION = PostgreSQL 8.3.8
```

Finally my feeble brain caught up with obvious reality. The build
process was working with files from PostgreSQL 8.3.8 (see the path to
<code>libpq-fe.h</code> in the error message), but it was unable to read
symbols from the PostgreSQL libraries. It was trying to read a 64-bit
library as if it were a 32-bit library. I took a closer look at the Ruby
and PostgreSQL binaries:

```sh
$ rvm use ree
Now using ree 1.8.7 2009.10 
$ file $(whence ruby)
/Users/jparker/.rvm/ree-1.8.7-2009.10/bin/ruby: Mach-O executable i386
$ file $(whence pg_config)
/opt/local/lib/postgresql83/bin/pg_config: Mach-O 64-bit executable x86_64
```

PostgreSQL was indeed built in 64-bit mode, but REE had somehow been
built in 32-bit mode. I rebuilt REE explicitly telling it to build in
64-bit mode:

```sh
$ export ARCHFLAGS="-arch x86_64"
$ rvm install ree
```

After verifying the new REE binary was indeed 64-bit, I took another
shot at rebuilding the ruby-pg gem. It worked perfectly. God's in his
heaven. All is right with the world.

Having opened and closed windows a number of times while trying to fix
the problem, I'm unable to verify the state of the environment in which
I originally upgraded REE, but I suspect I had a tainted
<code>ARCHFLAGS</code> environment variable left over from an earlier
task. The moral of the story is:

1.  When building software always make sure your environment is clean.
2.  Build everything 64-bit or nothing 64-bit.
3.  Before wasting prime pub hours fixing something that isn't broken
    (ruby-pg), consider what pieces have changed (REE) and investigate
    them first.

