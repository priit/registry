require 'rails_helper'

RSpec.describe 'registrar/profile/show' do
  let(:registrar) { instance_spy(Registrar) }

  before :example do
    assign(:registrar, registrar)
    stub_template 'registrar/billing_subscription/_for_profile' => 'billing subscription panel'
  end

  it 'has title' do
    render
    expect(rendered).to have_text('My profile')
  end

  it 'has billing subscription panel' do
    render
    expect(rendered).to have_text('billing subscription panel')
  end
end
