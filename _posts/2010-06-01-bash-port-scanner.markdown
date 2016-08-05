---
title: Bash Port Scanner
layout: post
---

I haven't done a very good job keeping up with features that have been
added to [Bash](http://www.gnu.org/software/bash/) over the years. While
sitting in on Hal Pomeranz's [Return of Command-Line Kung
Fu](http://opensourcebridge.org/sessions/349) talk at [Open Source
Bridge](http://opensourcebridge.org/) this year I picked up this gem:

```sh
$ for ((i=0; $i<1024; i++)); do
>  echo > /dev/tcp/localhost/$i && echo "tcp/$i is alive"
> done 2>/dev/null
tcp/22 is alive
tcp/80 is alive
…
```

I didn't know Bash supported C-style for loops, so I'm glad to have
learned of them. But I'm not quite sure how to feel about the magic
<code>/dev/tcp</code> "files" -- that seems potentially useful but so
very perverse. Search for "/dev/tcp" in the Bash man page to read more
about it (<code>/dev/udp</code> is also supported).
