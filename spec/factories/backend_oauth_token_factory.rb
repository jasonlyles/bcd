# Read about factories at http://github.com/thoughtbot/factory_bot
FactoryBot.define do
  factory :backend_oauth_token do
    provider { 'Etsy' }
    access_token { 'ABCD1234EF567' }
    refresh_token { '765FE4321CBA' }
  end
end
