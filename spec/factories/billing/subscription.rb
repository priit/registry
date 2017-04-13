FactoryGirl.define do
  factory :billing_subscription, class: Billing::Subscription do
    kind [Billing::Subscription.default_kind]
    balance_threshold 1
    amount 1
  end
end
