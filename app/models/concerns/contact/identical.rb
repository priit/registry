module Contact::Identical
  extend ActiveSupport::Concern

  IDENTIFIABLE_ATTRIBUTES = %w[
    name
    email
    phone
    fax
    ident
    ident_type
    ident_country_code
    org_name
  ]

  IDENTICAL_ATTRIBUTES = %w[
    ident
    ident_type
    ident_country_code
  ].freeze

  private_constant :IDENTIFIABLE_ATTRIBUTES

  def identical(registrar)
    self.class.where(identifiable_hash)
      .where(["statuses = ?::character varying[]", "{#{read_attribute(:statuses).join(',')}}"])
      .where(registrar: registrar)
      .where.not(id: id).take
  end

  def identical_to?(contact)
    IDENTICAL_ATTRIBUTES.all? do |attribute|
      attributes[attribute] == contact.attributes[attribute]
    end
  end

  private

  def identifiable_hash
    attributes = IDENTIFIABLE_ATTRIBUTES

    if self.class.address_processing?
      attributes += self.class.address_attribute_names
    end

    slice(*attributes)
  end
end
