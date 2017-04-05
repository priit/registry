require 'rails_helper'

RSpec.describe 'admin/registrars/_billing' do
  let(:registrar) { instance_double(Registrar) }

  before :example do
    expect(view).to receive(:registrar).and_return(registrar)
  end

  it 'has registrar billing email' do
    expect(registrar).to receive(:billing_email).and_return('test billing email')
    render
    expect(rendered).to have_text('test billing email')
  end
end
