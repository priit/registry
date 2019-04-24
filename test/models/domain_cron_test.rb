require 'test_helper'

class DomainCronTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @domain = domains(:shop)
    ActionMailer::Base.deliveries.clear
  end

  def test_clean_expired_pendings_notifies_registrant_by_email
    Setting.expire_pending_confirmation = 0
    @domain.update!(registrant_verification_asked_at: Time.zone.now,
                    registrant_verification_token: 'test',
                    statuses: [DomainStatus::PENDING_DELETE_CONFIRMATION])

    DomainCron.clean_expired_pendings

    assert_emails 1
  end
end