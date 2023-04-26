# frozen_string_literal: true

require 'spec_helper'

describe Pinterest::Api::AccessToken do
  describe 'self.store' do
    it 'should create a new token' do
      time = Time.now + 1.hour
      expect {
        Pinterest::Api::AccessToken.store('access_token', 'refresh_token', time)
      }.to change(BackendOauthToken, :count).by(1)

      bot = BackendOauthToken.last
      expect(bot.provider).to eq('pinterest')
      expect(bot.access_token).to eq('access_token')
      expect(bot.refresh_token).to eq('refresh_token')
      expect(bot.expires_at).to eq(time)
    end

    it 'should update an existing token' do
      bot = FactoryBot.create(:backend_oauth_token, provider: 'pinterest', access_token: 'old', refresh_token: 'even_older', expires_at: Time.now - 1.hour)
      time = Time.now + 1.hour

      expect {
        Pinterest::Api::AccessToken.store('access_token', 'refresh_token', time)
      }.not_to change(BackendOauthToken, :count)

      bot.reload

      expect(bot.provider).to eq('pinterest')
      expect(bot.access_token).to eq('access_token')
      expect(bot.refresh_token).to eq('refresh_token')
      expect(bot.expires_at).to eq(time)
    end
  end
end
