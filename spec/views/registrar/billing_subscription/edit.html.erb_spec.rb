require 'rails_helper'

RSpec.describe 'registrar/billing_subscription/edit' do
  before :example do
    stub_template '_form' => ''
  end

  it 'has title' do
    render
    expect(rendered).to have_text('Edit billing subscription')
  end
end
