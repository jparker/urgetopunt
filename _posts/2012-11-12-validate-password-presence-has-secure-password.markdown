---
title: Password validation and has_secure_password
layout: post
tags: rails
---

**UPDATE 2012-11-29:** Actually, it appears this will be [a moot point
in Rails 4](https://github.com/rails/rails/pull/6215).

If the authentication needs of your Rails application are simple enough,
third-party authentication libraries like
[Devise](https://github.com/plataformatec/devise),
[Authlogic](https://github.com/binarylogic/authlogic) or
[Clearance](https://github.com/thoughtbot/clearance) can introduce
considerable, unneeded overhead. Don't get me wrong. All three libraries
are well-written, well-maintained and popular enough that most support
is little more than a Google search away. Nevertheless, if your needs
are simple, you may find that Rails'
[SecurePassword](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)
does everything you need with a minimum of fuss.

One of the handy things <code>has_secure_password</code> does for you
is establish minimal validation rules for your password — the password
must be confirmed (by providing <code>password</code> and
<code>password_confirmation</code> attributes) and the
<code>password_digest</code> attribute must not be blank. These
validation rules are the absolute minimum you need to ensure users
aren't created with blank passwords, but you will almost certainly need
to augment them to provide a secure, user-friendly experience for your
application.

For starters, left as is, if you leave <code>password</code> and
<code>password_confirmation</code> blank, while validation will fail,
the validation errors might not be where you expect them.

```
[1] pry(main)> user = User.new(password: nil, password_confirmation: nil)
=> #<User id: nil, username: nil, email: nil, name: nil, password_digest: nil, created_at: nil, updated_at: nil>
[2] pry(main)> user.valid?
=> false
[3] pry(main)> user.invalid?(:password)
=> true
[4] pry(main)> user.errors[:password]
=> []
[5] pry(main)> user.errors[:password_confirmation]
=> []
[6] pry(main)> user.errors[:password_digest]
=> ["can't be blank"]
```

The password is indeed invalid, but the error message "can't be blank"
is attached to the <code>password_digest</code> attribute. The digest
is the encrypted hash in which the password is stored. It's contents are
never meant to be presented to the user. Only the <code>password</code>
and <code>password_confirmation</code> virtual attributes matter. You
probably don't want to tell the user the password digest can't be blank,
but rather the password itself can't be blank. When displaying error
messages you will have to jump through extra hoops to ensure that the
relevant error message is displayed meaningfully.

Of course, you will most likely want to add some additional validations
to your password field anyway if you intend to do any password vetting.
While you're at it, why not ensure the password isn't blank?

```ruby
class User < ActiveRecord::Base
  has_secure_password
  validates :password,
    presence: { on: :create },
    length: { minimum: 8, allow_blank: true }
end
```

Now if a user is created with a blank password, validation will fail and
the "can't be blank" error will show up on the <code>password</code>
attribute itself. The password will also have a minimum length. Throw in
some <code>validates_format_of</code> goodness if you must oblige
users to use more than one chracter class in their password (upper-case,
digits, punctuation). (Of course, obscure gibberish [isn't all it's
cracked up to be](http://xkcd.com/936/.))
