---
layout: post
---

```ruby
#!/usr/bin/env ruby
#
# ph - Parallel Heroku
#
# Quick and dirty way to run an heroku command against several apps in
# parallel. For example, if you want to see what version of ruby is being used
# on every app you currently have deployed on Heroku:
#
# ph run 'ruby --version'
#
# Use at your own risk.

args = ARGV
apps = %x{heroku apps}.split(/\n/).grep(/^[^=]/).map { |l| l.split[0] }

offset = apps.map(&:length).max

threads = apps.map do |app|
  Thread.new(app) do |app|
    IO.popen(['heroku', *args, '-a', app]) do |p|
      p.each do |output|
        puts "%-#{offset}s => %s" % [app, output]
      end
    end
  end
end

threads.each(&:join)
```
