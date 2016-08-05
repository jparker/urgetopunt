---
title: Faking POSTs to S3 in Cucumber
layout: post
---

I've been developing an application that allows users to upload files to
[Amazon S3](http://aws.amazon.com/s3/). The files will be on the order
of 100 MB each, and they will not require post-processing by the
application server.

Since uploads will be relatively time-consuming, it would be preferable
to upload the files directly to S3 rather than uploading to the
application server and then sending them to S3 in a background job. The
procedure for direct uploads is
[well-documented](http://developer.amazonwebservices.com/connect/entry.jspa?externalID=1434)
on the AWS developer community site. The application renders the upload
form which POSTs to S3, and upon successful completion of the upload, S3
responds with a redirect: a <code>303 See Other</code> status and a
location header. The URL in the location header is provided by the
application in a hidden input field on the upload form.

Development of the application is being driven with
[Cucumber](http://cukes.info/) and
[Capybara](http://github.com/jnicklas/capybara). In general I don't want
scenarios to actually communicate with S3. It would be slow, and it
would prevent scenarios from running without a network connection. Other
than one specially-tagged scenario validating the actual interaction
with S3, I'd like the POSTs to S3 and the resulting redirects to be
stubbed out.

[FakeWeb](http://github.com/chrisk/fakeweb) is a wonderful utility for
stubbing out web requests. You can configure it to intercept
<code>Net::HTTP</code> requests to specific URLs (or even URLs matching
a regular expression) and provide fixed responses. In this case, I
wanted to intercept POSTs to
<code>http://s3.amazonaws.com/BUCKET_NAME</code> and respond with the
expected <code>303</code> redirect (throughout the rest of this article,
BUCKET_NAME should be replaced with the name of the actual S3 bucket
being used).

Normally I would configure FakeWeb in a <code>Before</code> hook like
so:

```ruby
# features/support/hooks.rb
Before('@upload') do
  token = Token.first
  FakeWeb.register_uri(:post, 'http://s3.amazonaws.com/BUCKET_NAME',
    :status => [303, 'See Other'],
    :location => "http://example.com/tokens/#{token.to_param}/upload_complete")
end
```

Where REDIRECT_ACTION would be replaced with the path of the action to
which the user should be redirected. However, a <code>Before</code> hook
wouldn't work for me because the redirect URL was a member action for a
resource (<code>Token.first</code>) which is created during the scenario
(and thus, after any <code>Before</code> hooks are run). So FakeWeb was
instead configured from a step definition:

```ruby
# features/step_definitions/asset_steps.rb
When /^S3 uploads are stubbed out$/ do
  token = Token.first
  FakeWeb.register_uri(:post, 'http://s3.amazonaws.com/BUCKET_NAME',
    :status => [303, 'See Other'],
    :location => "http://example.com/tokens/#{token.to_param}/upload_complete")
end
```

Now by adding "When S3 uploads are stubbed out" to the scenario the
expected FakeWeb configuration is added to the environment.

Sadly, after doing this, the scenario didn't work as expected. Instead
of the POST to S3 being intercepted, the form seemed to be posting to
<code>/BUCKET_NAME</code> on the application server, causing a routing
error to be raised. I verified that the form had the full URL to S3 in
the <code>action</code> attribute (the form for uploading directly to S3
is complicated enough that I actually wrote a view spec for it). So why
was the Cucumber scenario POSTing the form locally?

After a bit of googling I ran across [this
thread](http://groups.google.com/group/fakeweb-users/browse_thread/thread/c361f0382299093b/830542b4cc08338f)
on the fakeweb-users mailing list. It seems
[Webrat](http://github.com/brynary/webrat) was ignoring the host
component when doing a form submission. I'm using
[Capybara](http://github.com/jnicklas/capybara) instead of Webrat, but I
wondered if the same thing might be happening here. A quick look at the
section "Calling remote servers" in the [Capybara
README](http://github.com/jnicklas/capybara/blob/master/README.rdoc)
reveals that, indeed, the default driver in Capybara --- rack-test ---
does not support calling out to remote URLs.

So I couldn't use FakeWeb to stub out the S3 form submission. Looking
back at [the fakeweb-users
thread](http://groups.google.com/group/fakeweb-users/browse_thread/thread/c361f0382299093b/830542b4cc08338f),
one of the suggestions was to create a special route which responds to
requests for <code>/BUCKET_NAME</code>. This felt kludgy, but I really
wanted to move forward.

Creating a whole controller just to handle a test felt excessive, so
instead I opted to play with [Rails
Metal](http://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal).
I generated a stub named S3Stub and configured it to handle POSTs to
<code>/BUCKET_NAME</code>.

```ruby
# app/metal/s3_stub.rb
class S3Stub
  def self.call(env)
    if Rails.env.cucumber? && env['PATH_INFO'] =~ %r{^/BUCKET_NAME} && env['REQUEST_METHOD'] == 'POST'
      request = Rack::Request.new(env)
      [303, {'Location' => request.params['success_action_redirect']}, ['See Other']]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
```

As configured, this handler will respond to requests for
<code>/BUCKET_NAME</code>, but it will only do so when running through
Cucumber (<code>Rails.env.cucumber?</code> is true) and only for HTTP
POST requests (<code>env['REQUEST_METHOD']</code> is POST). In
production these requests will return the expected response <code>404
Not Found</code>. Using Metal keeps the handler lightweight (no
controller, no additional routes), and I can even forego looking up the
Token for the redirect URL, instead extracting the URL from the actual
request, just as S3 would do.

(As an aside, S3 actually lets you work with individual buckets using
two different URLs --- <code>http://BUCKET_NAME.s3.amazonaws.com</code>
and <code>http://s3.amazonaws.com/BUCKET_NAME</code>. In general,
either way would work, but for the specific problem addressed above, you
**must** use the latter URL. The former would result in Cucumber
scenarios posting to <code>/</code> on the test server. You probably
don't want to stub out requests to your application's root URL.)

I admit, right now I am not fond of the way this is setup. It's
definitely a kludge, but it was a relatively simple approach, and it
works. Still, if there is an accepted best practice for this problem ---
or just a better way to handle it --- I'd love to know.
