---
layout: post
categories: [bootstrap, rails]
---

```haml
= f.fields_for :contests do |f|
  = a.panel do
    ...
```

vs

```haml
= a.panel do
  = f.fields_for :contests do |f|
    ...
```
