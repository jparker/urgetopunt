---
title: RailsConf Day Two
layout: post
---

Early morning session was [The Even Darker Art of Rails
Engines](http://en.oreilly.com/rails2009/public/schedule/detail/8497) by
James Adam. Good overview of Rails Engines as they are implemented in
Rails 2.3, including caveats of some of the shortcomings. One issue is
that when application routes and engine routes collide, the engine route
takes precedence. James considers this a
[bug](https://rails.lighthouseapp.com/projects/8994/tickets/2592-plugin-routes-override-application-routes)
(I'm inclined to agree). Another gotcha is migrations. Migrations in an
engine are not visible unless they are copied into the top-level
migrations directory, but this is tricky because the version
number/timestamp on a migration in the application may collide with that
of a migration in the engine. Finally, public assets that are bundled
with an engine must be copied into the application's public directory in
order to be visible to the web server. Overall, engines have a lot of
potential as well as room for improvement. As things stand, they are
reasonably easy to deal with across in-house applications, but it
becomes much more complicated when they are published by third parties.
It's also worth noting that Rails 3 promises to have mountable
applications based on Rails Engines and Merb Slices.

Late morning session was [In Praise of Non-Fixtured
Data](http://en.oreilly.com/rails2009/public/schedule/detail/8004) by
Kevin Barnes. It was interesting to see some of the options for avoiding
fixtures that have arisen although for day-to-day work I have already
switched over to [Factory
Girl](http://thoughtbot.com/projects/factory_girl). I doubt it's
rational, but the idea of data generators being added directly to the
model class bothers me. That's one of the reasons I stick with Factory
Girl.

Early afternoon session was "The Future of Deployment: A Killer Panel"
with Marc-André Cournoyer, Christian Neukirchen, Ryan Tomayko, Adam
Wiggins, Blake Mizerany and James Lindenbaum. The panel members
represented different layers of the deployment stack including
[Thin](http://code.macournoyer.com/thin/),
[Rack](http://rack.rubyforge.org/),
[Rack::Cache](http://tomayko.com/src/rack-cache/),
[Sinatra](http://www.sinatrarb.com/) and
[Heroku](http://www.heroku.com/). Discussion centered around how the
different components came into being, how they've come to interact and
how they might need to develop for the future. If I spent more time
working with complex deployment issues, I probably would have gotten
more out of this session, but as it is my needs are quite simple.

Mid afternoon session was [I Rock, I Suck, I Am -- Jumpstart Your
Journey to
Agile](http://en.oreilly.com/rails2009/public/schedule/detail/7035) by
Davis W. Frank. Davis went over some practices and guidelines that
helped him adapt to the Agile workflow. Sometimes it seems that Agile
pays off the same way that REST does -- it's a simple, well-structured
way to breakdown complex tasks.

Late afternoon session was Obie Fernandez's [Blood, Sweat and
Rails](http://en.oreilly.com/rails2009/public/schedule/detail/7721). An
interesting talk about some of the perils of launching a formal
consultancy. Dealing with contract lawyers and keeping up with
collections are serious drawbacks.
