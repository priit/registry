require 'rails_helper'

RSpec.feature 'Billing subscription cancellation' do
  background do
    Setting.api_ip_whitelist_enabled = false
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area
  end

  scenario 'cancels billing subscription' do
    visit registrar_profile_url
    click_link_or_button 'cancel_registrar_billing_subscription_btn'

    expect(page).to have_text('Billing subscription has been cancelled.')
  end
end
