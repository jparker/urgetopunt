---
title: Capistrano, Ruby 1.9 and SSH Gateways
layout: post
tags: capistrano
---

**UPDATE 2011-05-05 16:17 PST**: It looks like this has [been
resolved](/capistrano/2011/05/05/capistrano-ruby19-ssh-gateway-resolved.html)!

**UPDATE 2011-01-16 16:26 PST**: I've updated the data collection
[gist](https://gist.github.com/782206) to show conversion to CSV in case
that's useful. I've also included the
[code](https://gist.github.com/782305) I used to calculate the
statistics for each data set.

I use [Ruby](http://www.ruby-lang.org/) at work for systems
administration tasks on a daily basis. One particularly useful tool in
my arsenal is
[Capistrano](https://github.com/capistrano/capistrano/wiki). However, as
I began to transition my daily taks to Ruby 1.9 I noticed Capistrano was
running slowly. Tasks that normally took on the order of a couple
seconds could take tens of seconds and sometimes even minutes. I do not
yet know what the root cause of the problem is, and I'm not even sure
anyone else is having such a problem. After some hours of Googling, I
have yet to see a single page describing anything remotely like this.
I'm posting this in case anyone else has noticed something similar.

The problem appears to only occur when I am using an ssh gateway,
defined in my <code>Capfile</code> like so:

```ruby
set :gateway, "host.example.com"
```

With that line, Capistrano connects via ssh to host.example.com first
and from there connects via ssh to the target host. (Without the gateway
defined, Capistrano will connect via ssh directly to the target host.)
With an ssh gateway defined in my <code>Capfile</code> tasks run under
Ruby 1.9.2 are painfully slow. I collected some statistics quantifying
the problem.

I started with the following dead simple Capistrano task:

```ruby
role :all, %w[server1 server2 server3 server4 server5]
task :uptime, :roles => :all do
  run "uptime"
end
```

This task runs the <code>uptime</code> command on five different servers
running Debian Linux. I ran the task 100 times in succession on a 2.6
GHz Core 2 Duo MacBook Pro running OS X 10.6.6 using [Ruby Enterprise
Edition 2010.02](http://www.rubyenterpriseedition.com/) and Ruby
1.9.2p136 both installed via [RVM](http://rvm.beginrescueend.com/). I
ran the tests with and without an ssh gateway. In each case I had
[capistrano
2.5.19](http://rubygems.org/gems/capistrano/versions/2.5.19), [net-ssh
2.0.24](http://rubygems.org/gems/net-ssh/versions/2.0.24) and
[net-ssh-gateway
1.0.1](http://rubygems.org/gems/net-ssh-gateway/versions/1.0.1)
installed. I timed each run.

<script src="https://gist.github.com/782206.js?file=gistfile1.sh">
</script>
The raw data for all the runs are available
[as a gist](https://gist.github.com/782156). I used
[this code](https://gist.github.com/782305) to calculate the stats.
Below is the analysis of those figures. First, running Ruby Enterprise
Edition through an ssh gateway:

{:.table.table-bordered.table-hover.table-striped}
||real|user|sys|
|min|2.50s|0.50s|0.15s|
|max|3.93s|0.60s|0.21s|
|mean|2.61s|0.56s|0.17s|
|stddev|0.17s|0.02s|0.01s|
|median|2.56s|0.56s|0.17s|

And running the same task under Ruby Enterprise Edition without an ssh
gateway:

{:.table.table-bordered.table-hover.table-striped}
||real|user|sys|
|min|2.54s|0.47s|0.13s|
|max|3.13s|0.62s|0.18s|
|mean|2.61s|0.51s|0.14s|
|stddev|0.11s|0.02s|0.01s|
|median|2.58s|0.51s|0.14s|

And now the same task under Ruby 1.9.2 without an ssh gateway:

{:.table.table-bordered.table-hover.table-striped}
||real|user|sys|
|min|2.29s|0.64s|0.21s|
|max|3.35s|0.72s|0.23s|
|mean|2.41s|0.66s|0.21s|
|stddev|0.11s|0.01s|0.00s|
|median|2.42s|0.66s|0.21s|

And finally the same task under Ruby 1.9.2 through an ssh gateway:

{:.table.table-bordered.table-hover.table-striped}
||real|user|sys|
|min|3.54s|0.70s|0.23s|
|max|**279.17s**|1.83s|1.11s|
|mean|**66.80s**|0.96s|0.43s|
|stddev|**58.61s**|0.22s|0.18s|
|median|**50.64s**|0.92s|0.39s|

So REE with and without a gateway and 1.9.2 without a gateway each took
about 2.5 seconds to complete the task. That seems reasonable to me. But
cripes, the average runtime for that task under 1.9.2 with a gateway was
66.80 seconds, and the peak runtime was 279.17 seconds! The shortest
runtime was an almost forgiveable 3.54 seconds. If you look at
[the data](https://gist.github.com/782156#file_cap_ruby192_gw.csv) for that
run you will see the substantial swings in runtime. The standard
deviation was a moody 58.61 seconds. With a median runtime of 50.64
seconds, it would seem most of the runs are shorter than average, but
there are several exceptionally slow runs. Fourteen runs took two
minutes or longer.

Again, apart from knowing it has something to do with using an ssh
gateway, I haven't identified the actual problem yet. If you know what I
might be doing wrong, I'd love to know. If you don't know what's going
on, but you're having a similar problem, well, at least you're not
alone. In the meanwhile, I've modified my <code>Capfile</code> to let me
conditionally enable the ssh gateway:

```ruby
if ENV['CAP_SSH_GATEWAY']
  set :gateway, ENV['CAP_SSH_GATEWAY']
end

# Run without an ssh gateway
#   $ cap <task>
# Run through an ssh gateway
#   $ cap <task> CAP_SSH_GATEWAY=host.example.com
```

This allows me to continue using Ruby 1.9 for daily systems
administration tasks while I'm on a trusted network. When working from
an untrusted network, I can throw <code>CAP_SSH_GATEWAY</code> on the
end (and switch to Ruby 1.8 -- which is easy with
[RVM](http://rvm.beginrescueend.com/)).
