---
layout: post
categories: rails
---

```ruby
class Quote
  has_many :quoteables, dependent: :destroy
  has_many :receivables, through: :quoteables

  # :prepend option is required to get this callback to run before a
  # callback implicitly defined when has_many association is declared.
  before_destroy :abort_destroy_if_paid, prepend: true

  private

  def abort_destroy_if_paid
    return true if receivables.empty?
    errors[:base] << 'Cannot delete record because dependent receipts exist'
    false
  end
end

class Receipt
  has_many :receivables, dependent: :destroy
end

class Quoteable
  belongs_to :quote
  has_many :receivables, dependent: :restrict_with_error
end

class Receivable
  belongs_to :receipt
  belongs_to :quoteable
end
```
