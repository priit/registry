require 'rails_helper'

RSpec.feature 'Registrar profile' do
  background do
    Setting.api_ip_whitelist_enabled = false
    Setting.registrar_ip_whitelist_enabled = false
    sign_in_to_registrar_area
  end

  scenario 'shows profile' do
    visit registrar_profile_url
    expect(page).to have_text('My profile')
  end
end
