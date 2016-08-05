---
title: Parsing Google Data XML with Nokogiri
layout: post
categories: nokogiri
---

I recently starting working on a project which needs to consume Google's
[Shared Contacts
API](http://code.google.com/googleapps/domain/shared_contacts/gdata_shared_contacts_api_reference.html).
I decided to use [Nokogiri](http://nokogiri.org/) to parse the XML
feeds, but I ran into perplexing problem when using <code>#xpath</code>
to retrieve specific elements from the XML document. I wanted to
retrieave all of the <tt>entry</tt> tags (there were five in the
sample document) under the <tt>feed</tt> tag. Searching for
<tt>//feed/entry</tt> using <code>#xpath</code> failed, but
searching for <tt>feed entry</tt> using <code>#css</code> worked.

```ruby
doc = Nokogiri.XML(open("feed.xml")) # => #<Nokogiri::XML::Document:0x...>
doc.xpath('//feed/entry').size       # => 0 
doc.css('feed > entry').size         # => 5
```

While experimenting to figure out the problem I noticed that not all
XPath searches failed. For example searching for email addresses within
the contact feed using <tt>//gd:email</tt> returned the correct
number of elements. A bit of googling turned up this [article on Stack
Overflow](http://stackoverflow.com/questions/1157138/how-can-i-get-nokogiri-to-parse-and-return-an-xml-document).
Commenter [Pesto](http://stackoverflow.com/users/23921/pesto) pointed
out that, when using <code>#xpath</code>, you must use the fully
qualified XML namespaces, i.e., <tt>//xmlns:feed/xmlns:entry</tt>.

```ruby
doc.xpath('//xmlns:feed/xmlns:entry').size # => 5
```

I didn't catch on at the time, but that's why <tt>//gd:email</tt>
worked --- it included the namespace.
