class BouncedEmailsCleanerJob < ApplicationJob
  queue_as :default

  def perform
    BouncedMailAddress.find_each do |bounce|
      count = Contact.where(email: bounce.email).count
      if count.zero?
        logger.info "#{bounce.inspect} ARE DELETED!"
        bounce.destroy
      end
    end
  end

  private

  def logger
    @logger ||= Rails.logger
  end
end
