---
title: Rails Source Annotations and RSpec
layout: post
categories: rspec
---

By default Rails' [source
annotation](https://github.com/rails/rails/blob/master/railties/lib/rails/source_annotation_extractor.rb)
rake tasks (<tt>notes</tt> and its more specific children
<tt>notes:todo</tt>, <tt>notes:fixme</tt>, etc.) only search the
<tt>app</tt>, <tt>config</tt>, <tt>lib</tt>,
<tt>scripts</tt> and <tt>test</tt> directories of your
application. I use [RSpec](http://rspec.info), and on short notice,
dumping this file into <tt>lib/tasks</tt> of my application was the
best I could come up with to add <tt>spec</tt> to the annotation
search path.

```ruby
task :add_rspec_annotation_support do
  SourceAnnotationExtractor.class_eval do
    def self.enumerate(tag, options = {})
      extractor = new(tag)
      extractor.display(extractor.find(%w(app config lib script test spec)), options)
    end
  end
end

%w(notes notes:todo notes:fixme notes:optimize).each do |task|
  Rake::Task[task].enhance([:add_rspec_annotation_support])
end
```

(I know some people consider littering your code with notes to your
future self \[or future replacement\] to investigate and fix things is a
smell that could indicate you're lazy and/or bad at prioritizing. They
may well be right, but until I retrain myself, this helps.)
