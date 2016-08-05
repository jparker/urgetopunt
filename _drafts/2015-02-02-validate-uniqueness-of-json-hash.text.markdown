---
layout: post
categories: rails
---

```ruby
class Nominee < ActiveRecord::Base
  validate :metadata_is_unique

  def metadata=(payload)
    super.tap { set_digest }
  end

  private

  def metadata_is_unique
    if self.class.where(digest: digest).where.not(id: id).exists?
      errors.add :metadata, :taken
    end
  end

  def set_digest
    self.digest = normalize(metadata).hash.to_s(16)
  end

  def normalize(payload)
    case payload
    when Hash
      payload.map { |key, value|
        [key.downcase.squish, normalize(Array(value))].to_set
      }.to_set
    when Array
      payload.map { |e| e.downcase.squish }.to_set
    else
      payload
    end
  end
end
```
