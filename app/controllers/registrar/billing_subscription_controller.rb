class Registrar
  class BillingSubscriptionController < BaseController
    skip_authorization_check
    before_action :find_subscription, except: %i[new]
    helper_method :kinds

    def new
      @subscription = current_user.registrar.build_billing_subscription
    end

    def create
      @subscription = current_user.registrar.build_billing_subscription(subscription_params)
      @subscription.kind = @subscription.kind.reject { |value| value.blank? }

      if @subscription.save
        flash[:notice] = t('.created')
        redirect_to registrar_profile_url
      else
        render :new
      end
    end

    def edit
    end

    def update
      @subscription.attributes = subscription_params
      @subscription.kind = @subscription.kind.reject { |value| value.blank? }

      if @subscription.save
        flash[:notice] = t('.updated')
        redirect_to registrar_profile_url
      else
        render :edit
      end
    end

    def destroy
      @subscription.destroy!
      flash[:notice] = t('.destroyed')
      redirect_to registrar_profile_url
    end

    private

    def find_subscription
      @subscription = current_user.registrar.billing_subscription
    end

    def subscription_params
      params.require(:billing_subscription).permit(:balance_threshold, :amount, kind: [])
    end

    def kinds
      Billing::Subscription.kinds.map { |kind| Array.new(2, kind) }
    end
  end
end
