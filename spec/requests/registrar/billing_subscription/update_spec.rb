require 'rails_helper'

RSpec.describe 'registrar billing subscription update' do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user, registrar: registrar) }
  let!(:subscription) { create(:billing_subscription, registrar: registrar) }

  before :example do
    sign_in_to_registrar_area(user: user)
  end

  it 'updates kind' do
    patch registrar_billing_subscription_path, billing_subscription:
      attributes_for(:billing_subscription, kind: [Billing::Subscription.default_kind])
    subscription.reload

    expect(subscription.kind).to eq([Billing::Subscription.default_kind])
  end

  it 'updates balance threshold' do
    patch registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription,
                                                                                    balance_threshold: '1')
    subscription.reload

    expect(subscription.balance_threshold).to eq(Money.from_amount(1))
  end

  it 'updates amount' do
    patch registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription,
                                                                                    amount: '1')
    subscription.reload

    expect(subscription.amount).to eq(Money.from_amount(1))
  end

  it 'redirects to profile' do
    patch registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription)

    expect(response).to redirect_to registrar_profile_path
  end
end
