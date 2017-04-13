require 'rails_helper'
require 'views/shared_examples/money_form_field'

RSpec.describe 'registrar/billing_subscription/_form' do
  let(:billing_subscription) { build_stubbed(:billing_subscription) }

  before :example do
    stub_template '_form_errors.html.erb' => ''
    allow(view).to receive(:billing_subscription).and_return(billing_subscription)
  end

  describe 'balance threshold' do
    let(:field) { page.find_by_id('billing_subscription_balance_threshold') }

    it_behaves_like 'money form field'

    it 'is required' do
      render
      expect(field[:required]).to eq('required')
    end
  end

  describe 'amount' do
    let(:field) { page.find_by_id('billing_subscription_amount') }

    it_behaves_like 'money form field'

    it 'is required' do
      render
      expect(field[:required]).to eq('required')
    end
  end
end
