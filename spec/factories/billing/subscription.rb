FactoryGirl.define do
  factory :billing_subscription, class: Billing::Subscription do
    balance_threshold_cents 100
    amount_cents 100
  end
end
