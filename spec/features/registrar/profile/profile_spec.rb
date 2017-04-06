require 'rails_helper'

RSpec.feature 'Registrar area profile' do
  background do
    Setting.api_ip_whitelist_enabled = false
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area(user: create(:api_user_with_unlimited_balance))
  end

  it 'is visible' do
    visit registrar_profile_url
    expect(page).to have_text('My profile')
  end
end
