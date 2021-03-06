module Domains
  module BulkRenew
    class SingleDomainRenew < ActiveInteraction::Base
      object :domain,
             class: Epp::Domain
      integer :period
      string :unit
      object :registrar

      def execute
        in_transaction_with_retries do
          check_balance
          success = domain.renew(domain.valid_to, period, unit)
          if success
            check_balance
            reduce_balance
          else
            add_error
          end
        end
      end

      def check_balance
        compose(Domains::CheckBalance::SingleDomain,
                domain: domain,
                operation: 'renew',
                period: period,
                unit: unit)
      end

      def reduce_balance
        domain_pricelist = domain.pricelist('renew', period, unit)
        registrar.debit!(sum: domain_pricelist.price.amount,
                         description: "#{I18n.t('renew')} #{domain.name}",
                         activity_type: AccountActivity::RENEW,
                         price: domain_pricelist)
      end

      def in_transaction_with_retries
        if Rails.env.test?
          yield
        else
          transaction_wrapper { yield }
        end
      rescue ActiveRecord::StatementInvalid
        sleep rand / 100
        retry
      end

      def transaction_wrapper
        ActiveRecord::Base.transaction(isolation: :serializable) do
          yield if block_given?
        end
      end

      private

      def add_error
        domain.add_epp_error(2104, nil, nil, I18n.t(:domain_renew_error_for_domain))
        errors.add(:domain, I18n.t('domain_renew_error_for_domain', domain: domain.name))
      end
    end
  end
end
