require 'rails_helper'

RSpec.describe 'registrar/billing_subscription/_for_profile' do
  before :example do
    allow(view).to receive(:billing_subscription)
  end

  it 'has title' do
    render
    expect(rendered).to have_text('Billing subscription')
  end
end
