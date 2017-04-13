require 'rails_helper'

RSpec.describe Billing::Subscription do
  describe '::table_name', db: false do
    it 'returns table name' do
      expect(described_class.table_name).to eq('billing_subscriptions')
    end
  end

  describe '::kinds' do
    it 'returns valid type list' do
      expect(described_class.kinds).to eq(%w[e_invoice pdf])
    end
  end

  describe '::default_kind' do
    it 'returns default type' do
      expect(described_class.default_kind).to eq('e_invoice')
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

  describe 'kind validation', db: false do
    subject(:subscription) { described_class.new }

    it 'rejects absent' do
      subscription.kind = nil
      subscription.validate
      expect(subscription.errors).to have_key(:kind)
    end

    it 'rejects blank' do
      subscription.kind = []
      subscription.validate
      expect(subscription.errors).to have_key(:kind)
    end

    it 'rejects invalid' do
      allow(described_class).to receive(:kinds).and_return(%w[valid])
      subscription.kind = %w(invalid)
      subscription.validate
      expect(subscription.errors).to have_key(:kind)
    end

    it 'accepts valid' do
      allow(described_class).to receive(:kinds).and_return(%w[valid])
      subscription.kind = %w(valid)
      subscription.validate
      expect(subscription.errors).to_not have_key(:kind)
    end
  end

  describe 'balance threshold validation', db: false do
    subject(:subscription) { described_class.new }

    it 'rejects absent' do
      subscription.balance_threshold = nil
      subscription.validate
      expect(subscription.errors).to have_key(:balance_threshold)
    end

    it 'rejects zero' do
      subscription.balance_threshold = 0
      subscription.validate
      expect(subscription.errors).to have_key(:balance_threshold)
    end

    it 'accepts greater than zero' do
      subscription.balance_threshold = 1
      subscription.validate
      expect(subscription.errors).to_not have_key(:balance_threshold)
    end

    it 'accepts large number' do
      subscription.balance_threshold = 500000
      subscription.validate
      expect(subscription.errors).to_not have_key(:balance_threshold)
    end
  end

  describe 'amount validation', db: false do
    subject(:subscription) { described_class.new }

    it 'rejects absent' do
      subscription.amount = nil
      subscription.validate
      expect(subscription.errors).to have_key(:amount)
    end

    it 'rejects zero' do
      subscription.amount = 0
      subscription.validate
      expect(subscription.errors).to have_key(:amount)
    end

    it 'accepts greater than zero' do
      subscription.amount = 1
      subscription.validate
      expect(subscription.errors).to_not have_key(:amount)
    end

    it 'accepts large number' do
      subscription.amount = 500000
      subscription.validate
      expect(subscription.errors).to_not have_key(:amount)
    end
  end

  it 'allows only one billing subscription per registrar' do
    registrar = create(:registrar)
    create(:billing_subscription, registrar: registrar)

    expect { create(:billing_subscription, registrar: registrar) }.to raise_error(ActiveRecord::RecordNotUnique)
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
