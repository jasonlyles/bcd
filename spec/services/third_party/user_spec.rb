# frozen_string_literal: true

require 'spec_helper'

describe ThirdParty::User do
  describe 'self.find_or_create_user' do
    context 'with an existing user' do
      it 'should find and return the user' do
        user = FactoryBot.create(:user, email: 'steve@steve.net')

        found_user = nil
        expect {
          found_user = ThirdParty::User.find_or_create_user('etsy', 'steve@steve.net', '12345abcde')
        }.not_to change { User.count }

        expect(found_user).to eq(user)
      end
    end

    context 'without an existing user' do
      it 'should create and return the user' do
        expect {
          ThirdParty::User.find_or_create_user('etsy', 'steve@steve.net', '12345abcde')
        }.to change { User.count }.by(1)

        user = User.last

        expect(user.email).to eq('steve@steve.net')
        expect(user.source).to eq('etsy')
        expect(user.third_party_user_identifier).to eq('12345abcde')
        expect(user.guid).to_not be_nil
        expect(user.account_status).to eq('G')
        expect(user.tos_accepted).to eq(false)
        expect(user.email_preference).to eq('no_emails')
      end
    end
  end
end
