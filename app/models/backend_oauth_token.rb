# frozen_string_literal: true

class BackendOauthToken < ApplicationRecord
  validates :provider, :access_token, :refresh_token, :expires_at, presence: true
  validates :provider, uniqueness: true

  enum provider: %i[etsy pinterest]

  def self.token_current?(provider)
    return false unless send(provider).exists?

    send(provider).first.expires_at > Time.now
  end
end
