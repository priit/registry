module Billing
  class Subscription < ActiveRecord::Base
    self.table_name = 'billing_subscriptions'

    belongs_to :registrar, required: true

    monetize :balance_threshold_cents
    monetize :amount_cents
  end
end
