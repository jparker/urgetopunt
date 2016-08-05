---
title: Bootstrapping a Minimal RubyGem
layout: post
---

These are the steps I currently follow when starting a new project to be
distributed as a RubyGem. Let's assume the new RubyGem will be named
"wozziegoggle".

Bootstrap the project using [Bundler](http://gembundler.com/):

```
$ bundle gem wozziegoggle
```

I'm using [RSpec](http://relishapp.com/rspec) and
[Mocha](http://mocha.rubyforge.org) on new projects, so I add
development gem dependencies for each.

```ruby
# wozziegoggle.gemspec
Gem::Specification.new do |s|
  # …
  s.add_development_dependency 'rspec', '~>2.6.0'
  s.add_development_dependency 'mocha', '~>0.9.12'
end
```

I also create a basic <code>spec_helper.rb</code> file that
configures RSpec and requires needed libraries.

```ruby
# spec/spec_helper.rb
spec_dir = File.dirname(__FILE__)
lib_dir  = File.expand_path(File.join(spec_dir, '..', 'lib'))
$:.unshift(lib_dir)
$:.uniq!
RSpec.configure do |config|
  config.mock_with :mocha
end
require 'mocha'
require 'wozziegoggle'
```

The RSpec rake taks will also be needed, so I make changes to the
<code>Rakefile</code>. I'll also add a task which spawns IRB with the
gem libraries preloaded.

```ruby
# Rakefile
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
task :default => :spec
desc 'Start IRB with preloaded environment'
task :console do
  exec 'irb', "-I#{File.join(File.dirname(__FILE__), 'lib')}", '-rwozziegoggle'
end
```

I usually use
[ZenTest](http://www.zenspider.com/ZSS/Products/ZenTest/), specifically
<tt>autotest</ttt> so that the specs can by automatically re-run as
I'm developing. A discover file is needed to make sure there are sane
default mappings.

```ruby
# autotest/discover.rb
Autotest.add_discover {'rspec2'}
```

Finally, I'll create a <tt>.rspec</tt> (née
<tt>spec/spec.opts</tt>) file with any options I want
<tt>rspec</tt> to be run with.

```
# .rspec
--colour
```
