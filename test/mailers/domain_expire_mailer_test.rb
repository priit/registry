require 'test_helper'

class DomainExpireMailerTest < ActionMailer::TestCase
  def test_delivers_domain_expiration_email
    domain = domains(:shop)
    email = domain.registrar.email
    assert_equal 'shop.test', domain.name

    email = DomainExpireMailer.expired(domain: domain,
                                       registrar: domain.registrar,
                                       email: email).deliver_now

    assert_emails 1
    assert_equal I18n.t("domain_expire_mailer.expired.subject", domain_name: domain.name),
                 email.subject
  end

  def test_delivers_domain_expiration_soft_email
    domain = domains(:shop)
    email = domain.registrar.email
    assert_equal 'shop.test', domain.name

    email = DomainExpireMailer.expired_soft(domain: domain,
                                            registrar: domain.registrar,
                                            email: email).deliver_now

    assert_emails 1
    assert_equal I18n.t("domain_expire_mailer.expired_soft.subject", domain_name: domain.name),
                 email.subject
  end

  def test_delivers_domain_expiration_soft_email_if_auto_fd
    domain = domains(:shop)
    email_address = domain.registrar.email
    assert_not domain.force_delete_scheduled?
    travel_to Time.zone.parse('2010-07-05')
    email = 'some@strangesentence@internet.ee'

    Truemail.configure.default_validation_type = :regex

    contact = domain.admin_contacts.first
    contact.update_attribute(:email, email)
    contact.email_verification.verify

    assert contact.email_verification_failed?

    domain.reload

    assert domain.force_delete_scheduled?

    email = DomainExpireMailer.expired_soft(domain: domain,
                                            registrar: domain.registrar,
                                            email: email_address).deliver_now

    assert_emails 1
    assert_equal I18n.t("domain_expire_mailer.expired_soft.subject", domain_name: domain.name),
                 email.subject
  end
end
