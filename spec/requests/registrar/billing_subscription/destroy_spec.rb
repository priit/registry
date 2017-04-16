require 'rails_helper'

RSpec.describe 'registrar billing subscription destroy' do
  let!(:registrar) { create(:registrar) }
  let!(:user) { create(:api_user, registrar: registrar) }
  let!(:subscription) { create(:billing_subscription, registrar: registrar) }

  before :example do
    sign_in_to_registrar_area(user: user)
  end

  it 'deletes billing subscription' do
    expect { delete registrar_billing_subscription_path }.to change { Billing::Subscription.count }.from(1).to(0)
  end

  it 'redirects to profile' do
    delete registrar_billing_subscription_path
    expect(response).to redirect_to registrar_profile_path
  end
end
