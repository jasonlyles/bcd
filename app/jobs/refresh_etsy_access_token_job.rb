# frozen_string_literal: true

class RefreshEtsyAccessTokenJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    Etsy::Api::AccessToken.refresh
  end
end
