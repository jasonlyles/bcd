# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :backend_notification do
    message { 'Something important happened' }
  end
end
