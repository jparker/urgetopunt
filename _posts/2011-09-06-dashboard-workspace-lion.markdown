---
title: Restoring Old Dashboard Visibility in OS X Lion
layout: post
---

After a couple weeks working in OS X Lion, I'm generally underwhelmed
and occasionally irritated. A few behavioral changes in particular were
so annoying the only positivie thing I could say about them is Apple had
the good sense to let me undo them. (I wonder how long that will last.)

**Problem: The
[Dashboard](http://en.wikipedia.org/wiki/Dashboard_(software)) no longer
overlays the active workspace.** In Snow Leopard, activating the
Dashboard caused it to overlay the active
[workspace](http://en.wikipedia.org/wiki/Spaces_(software)). Where ever
there was a gap between widgets, the underlying workspace was visible.
This was useful for quickly accessing the calendar or calculator widgets
while leaving an application window visible for reference. In Lion, the
Dashboard is now treated as a workspace. When it appears it replaces the
active workspace, leaving the application windows completely obscured.

**Solution: Don't treat Dashboard as a space.** Go to System Preferences
→ Mission Control and uncheck the box labeled "Show Dashboard as a
space".

**Problem: The scrolling direction on the touchpad or mouse is
unintuitive.** Lion introduced the concept of "natural" scrolling.
Whereas before, sliding your fingers down the mouse or touchpad would
scroll the page down, in Lion, sliding your fingers down scrolls the
page up. Apple describes this as "Content tracks finger movement", which
is accurate enough, and in fact, it matches the behavior you see on most
touch devices including the iPhone and iPad. The problem is, unlike an
iPhone or iPad, when I'm using a touchpad or mouse, I'm not *touching*
the content. Natural scrolling feels natural on an iPhone, but I've got
[fifteen years of experience](http://en.wikipedia.org/wiki/Scroll_wheel)
telling me when I scroll my finger down on a mouse, the indicator on the
scrollbar will also scroll down, and therefore the content will slide
up. Lion tried to undo that, and I wasn't grateful.

**Solution: Disable natural scrolling.** Go to System Preferences →
Mouse → Point & Click and uncheck the box labeled "Scroll direction:
natural". You may have to do the same thing for your trackpad by going
to System Preferences → Trackpad → Scroll & Zoom (note that for the
trackpad it's the "Scroll & Zoom" tab, not the "Point & Click" tab).

I also had problems with trackpad swipe navigation on Google Chrome.
I've [written about the solution
already](/2011/08/24/trackpad-swipe-chrome-lion.html).
