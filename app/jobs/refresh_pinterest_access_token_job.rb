# frozen_string_literal: true

class RefreshPinterestAccessTokenJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    Pinterest::Api::AccessToken.refresh
  end
end
