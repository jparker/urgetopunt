---
title: Factory Girl and Guard
layout: post
---

I've kept [factory_girl](https://github.com/thoughtbot/factory_girl) in
my testing toolkit for some time now, and recently, I started using
[guard](https://github.com/guard/guard) to run my tests automatically as
I make changes. I wanted guard to run the appropriate model, controller
and request specs when I change a particular factory. Guard doesn't know
what to do with factory files by default, so I added the following to my
Guardfile:

```ruby
require 'active_support/inflector'

guard 'rspec', :version => 2 do
  # ...

  watch(%r{^spec/factories/(.+)\.rb$}) do |m|
    %W[
      spec/models/#{m[1].singularize}_spec.rb
      spec/controllers/#{m[1]}_controller_spec.rb
      spec/requests/#{m[1]}_spec.rb
    ]
  end
end
```

By convention, my factories are named after the plural form of the model
name, and the files live in <tt>spec/factories</tt>, so, for
example, my User factories are defined in
<tt>spec/factories/users.rb</tt>. I require
<tt>active_support/inflector</tt> at the top of the Guardfile
because I need access to <code>String#singularize</code> to convert the
plural factory name (also used in the name of controller and request
specs) into the singular model name. Then I call <code>#watch</code>
with the pattern matching the factory files and use the name of the
factory to build the array of specs that need to be run.
