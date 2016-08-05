---
layout: post
title: Base64.strict_encode64
tags: ruby
---

Ruby 1.9 introduced a nice addition to the Base64 module:
<code>Base64.strict_encode64</code>. Whereas
<code>Base64.encode64</code> prettifies its output with newlines,
<code>Base64.strict_encode64</code> yields output without any
superfluous line feeds.

```ruby
s = 'a' * 64
puts Base64.encode64 s
# >> YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFh
# >> YWFhYWFhYWFhYWFhYWFhYWFhYQ==
puts Base64.strict_encode64 s
# >> YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYQ==
```

This is a nice feature if you find yourself in need of
[RFC 4648-compliant](https://tools.ietf.org/html/rfc4648#section-3.1) output.
You need this, for example, if you are generating policy documents for a form
which <a href="http://aws.amazon.com/articles/1434">uploads directly to Amazon
S3</a>. In such a scenario, instead of sending <code>#gsub</code> to the output
of <code>encode64</code> to strip out line feeds you can simply call
<code>strict_encode64</code>.
