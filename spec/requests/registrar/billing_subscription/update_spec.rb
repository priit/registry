require 'rails_helper'

RSpec.describe Registrar::DomainsController do
  let(:registrar) { create(:registrar) }
  let(:user) { create(:api_user, registrar: registrar) }
  subject(:billing_subscription) { registrar.billing_subscription }

  before do
    sign_in_to_registrar_area(user: user)
  end

  it 'updates kind' do
    patch registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription,
                                                                                    kind: %w(e-invoice))
    billing_subscription.reload

    expect(billing_subscription.kind).to eq(%w(e-invoice))
  end

  it 'updates balance threshold' do
    patch registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription,
                                                                                    balance_threshold: '1')
    billing_subscription.reload

    expect(billing_subscription.balance_threshold).to eq(Money.from_amount(1))
  end

  it 'updates amount' do
    patch registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription,
                                                                                    amount: '1')
    billing_subscription.reload

    expect(billing_subscription.amount).to eq(Money.from_amount(1))
  end

  it 'redirects to profile' do
    patch registrar_billing_subscription_path, billing_subscription: attributes_for(:billing_subscription)

    expect(response).to redirect_to registrar_profile_path
  end
end
