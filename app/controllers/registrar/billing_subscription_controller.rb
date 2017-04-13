class Registrar
  class BillingSubscriptionController < BaseController
    skip_authorization_check

    attr_reader :billing_subscription

    helper_method :kinds

    def edit
      load_billing_subscription
    end

    def update
      load_billing_subscription

      billing_subscription.attributes = billing_subscription_params
      billing_subscription.kind = billing_subscription.kind.reject { |value| value.blank? }
      updated = billing_subscription.save

      if updated
        flash[:notice] = t('.updated')
        redirect_to registrar_profile_url
      else
        render :edit
      end
    end

    def destroy
      load_billing_subscription

      billing_subscription.destroy!

      flash[:notice] = t('.destroyed')
      redirect_to registrar_profile_url
    end

    private

    def load_billing_subscription
      @billing_subscription = if current_user.registrar.billing_subscription
                                current_user.registrar.billing_subscription
                              else
                                current_user.registrar.build_billing_subscription
                              end
    end

    def billing_subscription_params
      params.require(:billing_subscription).permit(:balance_threshold, :amount, kind: [])
    end

    def kinds
      Billing::Subscription.kinds.map { |kind| Array.new(2, kind) }
    end
  end
end
