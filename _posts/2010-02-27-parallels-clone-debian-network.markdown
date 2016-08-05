---
title: Parallels Desktop, Debian, Cloning VMs and Networking
layout: post
---

If you clone a [Parallels](http://www.parallels.com/) virtual machine
running [Debian](http://www.debian.org/) or
[Ubuntu](http://www.ubuntu.com/) you may find that the clone comes up
sans networking. I encountered this problem reproducibly with VMs
running Debian 5.0, Ubuntu 8.04 and Ubuntu 9.10. While <code>eth0</code>
exists and works on the source VM, it does not exist on the clones which
instead have <code>eth1</code>. Apparently this is a [known
issue](http://forum.parallels.com/showthread.php?t=31427) with
Debian-based distributions.

To get the network up on the cloned VMs edit the file
<code>/etc/network/interfaces</code>, replacing all references to
<code>eth0</code> with <code>eth1</code> (or whatever the interface ends
up being named on the clone). Save your changes and restart networking.

I was a little perplexed by this when it happened, but given how easy it
is to fix and how behind I am on my work, I just don't care.
