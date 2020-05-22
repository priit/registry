class DirectoInvoiceForwardJob < Que::Job
  def run(monthly: false, dry: false)
    @dry = dry
    (@month = Time.zone.now - 1.month) if monthly
    api_url = ENV['directo_invoice_url']
    sales_agent = Setting.directo_sales_agent
    payment_term = Setting.directo_receipt_payment_term
    @prepayment_product_id = Setting.directo_receipt_product_name

    @client = DirectoApi::Client.new(api_url, sales_agent, payment_term)
    monthly ? send_monthly_invoices : send_receipts
  end

  def send_receipts
    unsent_invoices = Invoice.where(in_directo: false).non_cancelled

    Rails.logger.info("[DIRECTO] Trying to send #{unsent_invoices.count} prepayment invoices")
    unsent_invoices.each do |invoice|
      unless valid_invoice_conditions?(invoice)
        Rails.logger.info "[DIRECTO] Invoice #{invoice.number} has been skipped"
        next
      end
      @client.invoices.add_with_schema(invoice: invoice.as_directo_json, schema: 'prepayment')
    end

    sync_with_directo
  end

  def send_monthly_invoices
    Registrar.where.not(test_registrar: true).find_each do |registrar|
      fetch_monthly_summary(registrar: registrar)
    end

    return unless @client.invoices.count.positive?

    sync_with_directo
  end

  def fetch_monthly_summary(registrar:)
    return unless registrar.cash_account

    summary = registrar.monthly_summary(month: @month)
    @client.invoices.add_with_schema(invoice: summary, schema: 'summary') unless summary.nil?
  end

  def assign_monthly_numbers
    if directo_counter_exceedable?(@client.invoices.count)
      raise 'Directo Counter is going to be out of period!'
    end

    min_directo    = Setting.directo_monthly_number_min.presence.try(:to_i)
    directo_number = [Setting.directo_monthly_number_last.presence.try(:to_i),
                      min_directo].compact.max || 0

    @client.invoices.each do |inv|
      directo_number += 1
      inv.number = directo_number
    end
  end

  def valid_invoice_conditions?(invoice)
    if invoice.account_activity.nil? || invoice.account_activity.bank_transaction.nil? ||
       invoice.account_activity.bank_transaction.sum.nil? ||
       invoice.account_activity.bank_transaction.sum != invoice.total
      return false

    end

    true
  end

  def sync_with_directo
    assign_monthly_numbers if @month
    Rails.logger.info("[Directo] - attempting to send following XML:\n #{@client.invoices.as_xml}")
    return if @dry

    res = @client.invoices.deliver(ssl_verify: false)
    process_directo_response(res.body, @client.invoices.as_xml)
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    Rails.logger.info('[Directo] Failed to communicate via API')
  end

  def process_directo_response(xml, req)
    Rails.logger.info "[Directo] - Responded with body: #{xml}"
    Nokogiri::XML(xml).css('Result').each do |res|
      if @month
        mark_invoice_as_sent(res: res, req: req)
      else
        inv = Invoice.find_by(number: res.attributes['docid'].value.to_i)
        mark_invoice_as_sent(invoice: inv, res: res, req: req)
      end
    end
  end

  def mark_invoice_as_sent(invoice: nil, res:, req:)
    directo_record = Directo.new(response: res.as_json.to_h,
                                 request: req, invoice_number: res.attributes['docid'].value.to_i)
    if invoice
      directo_record.item = invoice
      invoice.update(in_directo: true)
    else
      update_directo_number(num: directo_record.invoice_number)
    end

    directo_record.save!
  end

  def update_directo_number(num:)
    return unless num.to_i > Setting.directo_monthly_number_last.to_i

    Setting.directo_monthly_number_last = num.to_i
  end

  def directo_counter_exceedable?(invoice_count)
    min_directo    = Setting.directo_monthly_number_min.presence.try(:to_i)
    max_directo    = Setting.directo_monthly_number_max.presence.try(:to_i)
    last_directo   = [Setting.directo_monthly_number_last.presence.try(:to_i),
                      min_directo].compact.max || 0

    return true if max_directo && max_directo < (last_directo + invoice_count)

    false
  end
end