require 'rails_helper'

RSpec.describe Billing::SubscriptionPresenter do
  let(:subscription) { instance_double(Billing::Subscription) }
  let(:presenter) { described_class.new(subscription: subscription, view: view) }

  describe '#kind' do
    it 'returns comma-separated type list' do
      allow(subscription).to receive(:kind).and_return(%w[test1 test2])
      expect(presenter.kind).to eq('test1, test2')
    end
  end

  describe '#balance_threshold' do
    before :example do
      allow(subscription).to receive(:balance_threshold).and_return(1)
      expect(view).to receive(:number_to_currency).with(1).and_return('test')
    end

    it 'returns localized balance threshold' do
      expect(presenter.balance_threshold).to eq('test')
    end
  end

  describe '#amount' do
    before :example do
      allow(subscription).to receive(:amount).and_return(1)
      expect(view).to receive(:number_to_currency).with(1).and_return('test')
    end

    it 'returns localized amount' do
      expect(presenter.amount).to eq('test')
    end
  end

  describe '#subscribe_btn' do
    context 'when not subscribed' do
      let(:subscription) { nil }

      it 'returns subscribe link' do
        html = view.link_to t('registrar.billing_subscription.subscription.subscribe_btn'),
                            new_registrar_billing_subscription_path,
                            id: 'registrar_billing_subscription_subscribe_btn',
                            class: 'btn btn-primary btn-sm'
        expect(presenter.subscribe_btn).to eq(html)
      end
    end

    context 'when subscribed' do
      it 'returns nothing' do
        expect(presenter.subscribe_btn).to be_nil
      end
    end
  end

  describe '#cancel_btn' do
    context 'when subscribed' do
      it 'returns cancellation link' do
        html = link_to t('registrar.billing_subscription.subscription.cancel_btn'),
                       registrar_billing_subscription_path,
                       method: :delete,
                       data: { confirm: t('registrar.billing_subscription.subscription.cancel_btn_confirm') },
                       id: 'cancel_registrar_billing_subscription_btn',
                       class: 'btn btn-danger btn-sm'

        expect(presenter.cancel_btn).to eq(html)
      end
    end

    context 'when not subscribed' do
      let(:subscription) { nil }

      it 'returns nothing' do
        expect(presenter.cancel_btn).to be_nil
      end
    end
  end
end
