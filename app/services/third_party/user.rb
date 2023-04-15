# frozen_string_literal: true

module ThirdParty
  class User
    def self.find_or_create_user(source, email, third_party_user_identifier)
      user = ::User.where(email:).first
      return user if user.present?

      Guest.create!(
        email:,
        source:,
        email_preference: 0,
        skip_tos_accepted: true,
        third_party_user_identifier:,
        account_status: 'G'
      )
    end
  end
end
