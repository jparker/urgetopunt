---
title: RailsConf Day Four
layout: post
---

I attended [HTTP's Best-Kept Secret:
Caching](http://en.oreilly.com/rails2009/public/schedule/detail/8739)
with Ryan Tomayko for the early morning session. Ryan gave a brief
overview of different types of HTTP caching (client, shared proxy and
gateway), eventually focusing on the server-side gateway caching. This
form of caching still sends data over the wire, but allows you to avoid
hitting Rails entirely, or else -- using something like
[ETags](http://en.wikipedia.org/wiki/HTTP_ETag) -- allows you to
minimize the amount of work done within Rails to generate the content.
It sounds like HTTP caching in its current form is still a bit awkward
to handle when the content of the response varies based on session
state, e.g., whether or not the user is logged in.

Mid morning session found me at [When to Tell Your Kids About
Presentation
Caching](http://en.oreilly.com/rails2009/public/schedule/detail/7485)
with Matthew Deiters. This covered some of the same material as the
previous caching talk, but Matthew focused more on minimizing the amount
of data sent over the wire. In addition to client-side caching, he
covered some general tips on reducing the size of the server responses.
Tips included reducing the number of resources (e.g., use Rails' asset
caching functionality to condense multiple javascript/CSS files into
fewer \[but larger\] files) and reducing the size of resources through
minification (obfuscation) and compression (e.g., Apache's
mod\_deflate).

My late morning session was [It's Not Always Sunny in the Clouds:
Lessons
Learned](http://en.oreilly.com/rails2009/public/schedule/detail/6967)
with Mike Subelsky. Mike described some of the surprises and challenges
he encountered over the past year working with [Amazon
EC2](http://aws.amazon.com/ec2/). He's still a fan of the power and
convenience introduced by cloud computing, but he's developed a healthy
respect for the complications and expenses it introduces over the old
tangible, colocated server route. Turnkey provisioning rocks, but it
involves a lot of work.
