module Billing
  class SubscriptionPresenter
    def initialize(subscription:, view:)
      @subscription = subscription
      @view = view
    end

    def kind
      subscription.kind.join(', ')
    end

    def balance_threshold
      view.number_to_currency(subscription.balance_threshold)
    end

    def amount
      view.number_to_currency(subscription.amount)
    end

    def subscribe_btn
      unless subscribed
        view.link_to view.t('registrar.billing_subscription.subscription.subscribe_btn'),
                     view.new_registrar_billing_subscription_path,
                     id: 'registrar_billing_subscription_subscribe_btn',
                     class: 'btn btn-primary btn-sm'
      end
    end

    def cancel_btn
      if subscribed
        view.link_to view.t('registrar.billing_subscription.subscription.cancel_btn'),
                     view.registrar_billing_subscription_path,
                     method: :delete,
                     data: { confirm: view.t('registrar.billing_subscription.subscription.cancel_btn_confirm') },
                     id: 'cancel_registrar_billing_subscription_btn',
                     class: 'btn btn-danger btn-sm'
      end
    end

    private

    attr_reader :subscription
    attr_reader :view
    alias_method :subscribed, :subscription
  end
end
