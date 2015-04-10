class Invoice < ActiveRecord::Base
  belongs_to :seller, class_name: 'Registrar'
  belongs_to :buyer, class_name: 'Registrar'
  has_many :invoice_items
  accepts_nested_attributes_for :invoice_items

  validates :invoice_type, :due_date, :currency, :seller_name, :seller_iban, :buyer_name, :invoice_items, :vat_prc, presence: true

  def seller_address
    [seller_street, seller_city, seller_state, seller_zip].reject(&:blank?).compact.join(', ')
  end

  def buyer_address
    [buyer_street, buyer_city, buyer_state, buyer_zip].reject(&:blank?).compact.join(', ')
  end

  def seller_country
    Country.new(seller_country_code)
  end

  def buyer_country
    Country.new(buyer_country_code)
  end

  def items
    invoice_items
  end

  def total_without_vat
    items.map(&:item_total_without_vat).sum
  end

  def total_vat
    total_without_vat * vat_prc
  end

  def total
    total_without_vat + total_vat
  end
end
