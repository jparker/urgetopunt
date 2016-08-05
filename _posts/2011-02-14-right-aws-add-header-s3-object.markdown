---
title: Adding a Header to an Existing S3 Object
layout: post
categories: s3
---

Two-thirds of the way through a substantial bulk upload of objects to
[S3](http://aws.amazon.com/s3) I realized I had forgotten to add a
header to the objects I was uploading. Specifically, I wanted each
object to have a Content-Disposition header to coax browsers into saving
objects with a specific filename rather than displaying them inline or
saving them with the long, unwieldy key name that had been generated for
the objects.

I certainly wouldn't want to upload the files all over again just to add
a header. Thankfully it's easy enough to add the header without
resending the content of the file by simply moving the key onto itself,
i.e., move the object but let the source key and the destination key be
identical. Using the
[right_aws](http://github.com/rightscale/right_aws) gem this is
accomplished easily enough:

```ruby
s3 = RightAws::S3.new(AMAZON_ACCESS_KEY_ID, AMAZON_SECRET_ACCESS_KEY)
s3.interface.move(
  BUCKET_NAME, "foo.txt", # source bucket and key
  BUCKET_NAME, "foo.txt", # destination bucket and key
  :replace,
  'Content-Disposition'=>'attachment; filename="bar.txt"')
```

The above snippet adds a Content-Disposition header to the object with
key <tt>foo.txt</tt>. Browsers respecting the Content-Disposition
header would try to download the file and save it with the name
<tt>bar.txt</tt> rather than trying to display it inline. This comes
in handy if your key names tend to run long because you must embed
additional information in them but would rather the user did not have
put up with that when downloading the object.
