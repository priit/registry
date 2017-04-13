module Billing
  class Subscription < ActiveRecord::Base
    self.table_name = 'billing_subscriptions'

    self.auto_html5_validation = false

    belongs_to :registrar, required: true

    monetize :balance_threshold_cents
    monetize :amount_cents

    validates :kind, presence: true
    validates :balance_threshold, :amount, numericality: { greater_than: 0 }
    validate :kind_must_be_valid

    def self.kinds
      %w[e_invoice pdf]
    end

    def self.default_kind
      kinds.first
    end

    private

    def kind_must_be_valid
      return unless kind

      if kind.detect { |i| !self.class.kinds.include?(i) }
        errors.add(:kind, :invalid)
      end
    end
  end
end
