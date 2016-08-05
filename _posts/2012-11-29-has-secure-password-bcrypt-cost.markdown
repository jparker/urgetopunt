---
title: Lowering BCrypt cost with has_secure_password
layout: post
categories: rails
---

One of the strengths of an algorithm like
[BCrypt](http://en.wikipedia.org/wiki/Bcrypt) for storing encrypted
passwords lies in the fact that it is relatively slow and can readily be
made slower. This makes brute force attacks time-prohibitive. The
[bcrypt-ruby](https://rubygems.org/gems/bcrypt-ruby) gem gives you easy
access to this cost factor to slow down encryption as needed. The
default cost is 10. This provides good security for encrypting user
passwords, but if your Rails application depends on users being signed
in, you may find this default cost has a substantial impact on the
performance of your integration tests. Both
[Devise](https://github.com/plataformatec/devise) and
[Authlogic](https://github.com/binarylogic/authlogic) provide hooks into
their BCrypt interface which allows you to easily change the cost, and
this can come in very handy during testing.

```ruby
# Place in test_helper.rb or spec_helper.rb
Devise.setup do |config|
  config.stretches = 1
end
```

```ruby
# Place in test_helper.rb or spec_helper.rb
AuthLogic::CryptoProviders::BCrypt.cost = 1
```

If you're authentication needs are simple and you have instead opted to
use Rails'
[SecurePassword](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password),
you will find that, at least as of Rails 3.2.9, there is no obvious way
to lower the cost factor. However, if you're willing to live with a
little monkey patching, you can achieve the same results.

```ruby
# Place in test_helper.rb, spec_helper.rb or spec/support/...
require 'bcrypt'

class BCrypt::Password
  class << self
    method = instance_method(:create)
    define_method :create do |arg, options = {cost: 1}|
      method.bind(self).call(arg, options)
    end
  end
end
```

Is it worth doing? Here are the before and after measurements on an
application I'm currently working on. This particular application is an
internal application for a client. There are no guest features, which
means every single feature depends on a user having first signed in.

Before&hellip;

```
$ SPEC_OPTS="--seed 48858" bundle exec rspec ./spec/features
..................................................................................................................

Finished in 42.67 seconds
114 examples, 0 failures

Randomized with seed 48858
```

&hellip;and after&hellip;

```
$ SPEC_OPTS="--seed 48858" bundle exec rspec ./spec/features
..................................................................................................................

Finished in 27.36 seconds
114 examples, 0 failures

Randomized with seed 48858
```

Before the change the integration tests run in 43 seconds; after the
change the tests run in 27 seconds. That's roughly a 37 percent
speed-up. I'll take it.
