require 'rails_helper'

RSpec.describe 'admin/registrars/show' do
  let(:registrar) { build_stubbed(:registrar) }

  before :example do
    assign(:registrar, registrar)
    stub_template 'shared/_title' => ''
  end

  it 'has registrar billing email' do
    expect(registrar).to receive(:billing_email).and_return('test billing email')
    render
    expect(rendered).to have_text('test billing email')
  end
end
