require 'rails_helper'

RSpec.describe Billing::Subscription do
  describe '::table_name', db: false do
    it 'returns table name' do
      expect(described_class.table_name).to eq('billing_subscriptions')
    end
  end

  describe 'registrar validation', db: false do
    subject(:subscription) { described_class.new }

    it 'rejects absent' do
      subscription.registrar = nil
      subscription.validate
      expect(subscription.errors).to have_key(:registrar)
    end
  end

  describe '#balance_threshold', db: false do
    subject(:subscription) { described_class.new(balance_threshold_cents: 100) }

    it 'returns balance threshold as money' do
      expect(subscription.balance_threshold).to eq(Money.from_amount(1))
    end
  end

  describe '#amount', db: false do
    subject(:subscription) { described_class.new(amount_cents: 100) }

    it 'returns amount as money' do
      expect(subscription.amount).to eq(Money.from_amount(1))
    end
  end
end
