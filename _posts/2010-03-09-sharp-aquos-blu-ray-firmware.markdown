---
title: Updating Firmware on Sharp BD-HP20U Blu-ray Player
layout: post
---

Updating the firmware on a Sharp BD-HP20U Blu-ray player using a USB
stick and a Mac was not entirely straightforward for me. The process is
a bit brittle, so I'm documenting it in the hopes that I (and others)
won't waste so much time dealing with it next time around.

[Sharp](http://www.sharpusa.com/) distributes the firmware update as a
ZIP archive. After you download and unpack it you will have a file with
a <tt>.RVP</tt> extension, e.g., <tt>HP20U118.RVP</tt>. This
file needs to be placed on the USB stick which will then be attached to
the Blu-ray player, but the player will be finicky about the condition
of the USB device.

The filesystem on the USB stick must be FAT16 -- the player will not
read FAT32. DiskUtility.app only seems able to do FAT32, so I had to
drop into the shell and use <tt>/sbin/newfs_msdos</tt> to format
the device. Plug the stick into your Mac and launch Terminal.app. From
the terminal make sure the USB stick is unmounted (replace
<tt>/dev/diskX</tt> with the actual device file of the USB stick):

```
$ diskutil umountdisk /dev/diskX
```

Next, format the USB stick with a FAT16 filesystem (again, replace
<tt>/dev/diskX</tt> as appropriate):

```
$ newfs_msdos -F 16 -v FIRMWARE /dev/diskX
```

The <tt>-F 16</tt> option specifies the FAT16 filesystem, and
<tt>-v FIRMWARE</tt> assigns the label "FIRMWARE" to the new
filesystem. You can use any 1-11 character string that adheres to DOS
file-naming rules instead of "FIRMWARE". Whatever you use will end up
being all uppercase regardless of how you enter it. See the
<tt>newfs_msdos</tt> man page for more information.

Now remount the USB stick:

```
$ diskutil mount /dev/diskX
```

This will mount the USB stick on <tt>/Volumes/FIRMWARE</tt> (the
mount point is derived from the volume label).

Now copy the <tt>.RVP</tt> file onto the USB stick (replace
<tt>/path/to/HP20U118.RVP</tt> with the actual path to whatever
firmware version you downloaded):

```
$ cp /path/to/HP20U118.RVP /Volumes/FIRMWARE
```

Quickly ensure that there are **no** other files on the USB stick other
than the <tt>.RVP</tt> file you just copied over:

```
$ ls -a /Volumes/FIRMWARE
```

Besides the firmware update, there may be several hidden files. They
must be removed before the device can used by the Blu-ray player. If
there are any, *any* other files on the disk besides the firmware update
itself, the Blu-ray player will refuse to run the update complaining
there are other files on the disk.

```
$ rm -rvf /Volumes/FIRMWARE/.[a-zA-Z0-9_]*
```

This command will verbosely remove any hidden files. If for any reason
there are any regular files (files whose names do not begin with a dot)
besides the firmware update, they should be remove as well.

Finally, unmount the USB device:

```
$ diskutil umountDisk /dev/diskX
```

When this completes the USB device can be safely unplugged from your
Mac. Plug it into your Blu-ray player and follow the operating manual
instructions for applying firmware updates. At the time of this writing
the operating manual for the HP-BD20U is [available
here](http://www.sharpusa.com/downloads/archives/product_manuals/dvd_man_BDHP20U.pdf).
