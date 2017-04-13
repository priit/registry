require 'rails_helper'

RSpec.feature 'Billing subscription update' do
  background do
    Setting.api_ip_whitelist_enabled = false
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area
  end

  scenario 'updates billing subscription' do
    visit registrar_profile_url
    click_link_or_button 'edit_registrar_billing_subscription_btn'

    select_kind
    fill_in 'billing_subscription_balance_threshold', with: '1'
    fill_in 'billing_subscription_amount', with: '2'
    click_link_or_button 'Save'

    expect(page).to have_text('Billing subscription has been updated.')
  end

  def select_kind
    check "billing_subscription_kind_#{Billing::Subscription.default_kind}"
  end
end
