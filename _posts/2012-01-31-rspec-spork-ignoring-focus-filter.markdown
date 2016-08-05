---
title: RSpec + Spork Ignoring Filters
layout: post
tags: rspec
---

I'm posting this as a reminder to myself and as Google fodder to raise
awareness of [this
discussion](https://github.com/sporkrb/spork/issues/166).

Most of the Rails projects I have in active development use
[RSpec](http://rspec.info) for testing. I also use
[Spork](https://github.com/sporkrb/spork) to preload the Rails
environment, allowing the tests to run more quickly. When I'm actively
working on a specfic example, particularly relatively slow-running
[request
specs](https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec),
I'll often use the <code>:focus</code> tag to filter out the specs I
don't need to run. I have the following set up in my RSpec
<code>configure</code> block:

```ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
```

Then I tag the spec I'm working on with <code>:focus</code> like so:

```ruby
# spec/requests/some_feature_spec.rb
describe 'SomeFeature' do
  it 'successfully does awesome stuff', :focus do
    # test awesome behavior
  end
end
```

I then go to work implementing the feature, periodically checking the
window running RSpec to observe my progress towards getting the feature
working as described.

At some point recently — apparently after upgrading to RSpec 2.8 — I
noticed the <code>:focus</code> tag being ignored. When I'd save my
changes, instead of the one focused example being run, the entire spec
file was being run. On a slow-running request spec, this could be
annoying, especially if I wanted to scroll through the
<tt>log/test.log</tt> file to debug exactly what was happening in
the database as the log output was cluttered with unrelated examples.

After spending some time composing suitable Google-fu to find reports of
similar problems I ran across
[#166](https://github.com/sporkrb/spork/issues/166) on Spork's Github
issue tracker. The problem seems to rest in RSpec 2.8 somewhere, and the
fix (or, at the very least, workaround) is relatively simple: add
<kbd>--tag focus</kbd> to the <tt>.rspec</tt> file at the root of
your project.

(As an added reminder, don't forget to set
<code>run_all_when_everything_filtered</code> to true in your
<code>RSpec.configure</code> block to ensure all your specs are eligible
for running when nothing is tagged with <code>:focus</code>.)
