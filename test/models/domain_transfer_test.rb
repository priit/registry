require 'test_helper'

class DomainTransferTest < ActiveSupport::TestCase
  setup do
    @domain_transfer = domain_transfers(:shop)
  end

  def test_approval
    @domain_transfer.approve
    @domain_transfer.reload
    assert @domain_transfer.approved?
  end

  def test_notifies_old_registrar_on_approval
    old_registrar = @domain_transfer.old_registrar

    assert_difference -> { old_registrar.notifications.count } do
      @domain_transfer.approve
    end

    text = 'Transfer of domain shop.test has been approved.' \
      ' It was associated with registrant john-001' \
      ' and contacts acme-ltd-001, jane-001, william-001.'
    id = @domain_transfer.id
    class_name = @domain_transfer.class.name

    notification = old_registrar.notifications.last
    assert_equal text, notification.text
    assert_equal id, notification.attached_obj_id
    assert_equal class_name, notification.attached_obj_type
  end

  def test_does_not_reuse_identical_contacts_on_transfer
    # Create identical contact and assign it to domain
    domain = @domain_transfer.domain
    identical_contact = domain.contacts.first.transfer(domain.registrar)

    assert_equal 3, domain.domain_contacts.count
    domain.domain_contacts.create!(contact: identical_contact, type: 'AdminDomainContact')

    assert_equal 4, domain.domain_contacts.count

    @domain_transfer.approve
    @domain_transfer.reload
    domain.reload

    assert @domain_transfer.approved?
    assert_equal 4, domain.domain_contacts.count
    assert_equal domain.registrar, @domain_transfer.new_registrar
  end
end
