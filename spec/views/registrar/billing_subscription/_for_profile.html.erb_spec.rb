require 'rails_helper'

RSpec.describe 'registrar/billing_subscription/_for_profile' do
  let(:subscription) { instance_double(Billing::Subscription) }
  let(:presenter) { instance_spy(Billing::SubscriptionPresenter) }

  before :example do
    allow(view).to receive(:subscription).and_return(subscription)
    allow(Billing::SubscriptionPresenter).to receive(:new).and_return(presenter)
  end

  it 'has title' do
    render
    expect(rendered).to have_text('Billing subscription')
  end

  context 'when subscribed' do
    visible_attributes = %i(
      kind
      balance_threshold
      amount
    )

    visible_attributes.each do |attr_name|
      it "has #{attr_name}" do
        expect(presenter).to receive(attr_name).and_return("test-#{attr_name}")
        render
        expect(rendered).to have_text("test-#{attr_name}")
      end
    end

    it 'has no hint' do
      render
      expect(rendered).to_not have_text(unsubscribed_text)
    end
  end

  context 'when not subscribed' do
    let(:subscription) { nil }

    it 'has hint' do
      render
      expect(rendered).to have_text(unsubscribed_text)
    end
  end

  def unsubscribed_text
    t('registrar.billing_subscription.for_profile.unsubscribed')
  end
end
