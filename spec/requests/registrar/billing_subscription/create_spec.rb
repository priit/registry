require 'rails_helper'

RSpec.describe 'registrar billing subscription create' do
  let!(:registrar) { create(:registrar) }
  let!(:user) { create(:api_user, registrar: registrar) }
  subject(:subscription) { registrar.billing_subscription }

  before :example do
    sign_in_to_registrar_area(user: user)
  end

  it 'creates new subscription' do
    expect { post registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription) }
      .to change { Billing::Subscription.count }.from(0).to(1)
  end

  it 'saves kind' do
    post registrar_billing_subscription_path,
         billing_subscription: attributes_for(:billing_subscription, kind: [Billing::Subscription.default_kind])
    expect(subscription.kind).to eq([Billing::Subscription.default_kind])
  end

  it 'saves balance threshold' do
    post registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription,
                                                                                   balance_threshold: '1')
    expect(subscription.balance_threshold).to eq(Money.from_amount(1))
  end

  it 'saves amount' do
    post registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription,
                                                                                   amount: '1')
    expect(subscription.amount).to eq(Money.from_amount(1))
  end

  it 'redirects to profile' do
    post registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription)

    expect(response).to redirect_to registrar_profile_path
  end
end
