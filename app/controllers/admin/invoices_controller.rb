module Admin
  class InvoicesController < BaseController
    load_and_authorize_resource

    def new
      @deposit = Deposit.new
    end

    def create
      r = Registrar.find_by(id: deposit_params[:registrar_id])
      @deposit = Deposit.new(deposit_params.merge(registrar: r))
      @invoice = @deposit.issue_prepayment_invoice

      if @invoice&.persisted?
        flash[:notice] = t(:record_created)
        redirect_to [:admin, @invoice]
      else
        flash.now[:alert] = t(:failed_to_create_record)
        render 'new'
      end
    end

    def cancel_paid
      invoice_id = params[:invoice_id]
      invoice = Invoice.find(invoice_id)

      if account_activity_with_negative_sum(invoice)
        flash[:notice] = t(:payment_was_cancelled)
      else
        flash[:alert] = t(:failed_to_payment_cancel)
      end
      redirect_to admin_invoices_path
    end

    def index
      @q = Invoice.includes(:account_activity).search(params[:q])
      @q.sorts = 'number desc' if @q.sorts.empty?
      @invoices = @q.result.page(params[:page])
    end

    def show; end

    def cancel
      @invoice.cancel
      redirect_to [:admin, @invoice], notice: t('.cancelled')
    end

    def download
      filename = "invoice-#{@invoice.number}.pdf"
      send_data @invoice.as_pdf, filename: filename
    end

    private

    def deposit_params
      params.require(:deposit).permit(:amount, :description, :registrar_id)
    end

    def account_activity_with_negative_sum(invoice)
      account_activity = AccountActivity.find_by(invoice_id: invoice.id)
      account_activity_dup = account_activity.dup
      account_activity_dup.sum = -account_activity.sum.to_i
      account_activity_dup.save
      account_activity.update(invoice_id: nil)
      account_activity_dup.update(invoice_id: nil)
      mark_cancelled_payment_order(invoice)
      account_activity.save && account_activity_dup.save
    end

    def mark_cancelled_payment_order(invoice)
      payment_order = invoice.payment_orders.last
      payment_order.update(notes: 'Cancelled')
    end
  end
end
