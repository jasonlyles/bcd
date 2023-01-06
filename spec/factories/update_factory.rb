# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :update do
    title { 'Super Update Time' }
    description { 'Time for an update!' }
    body { 'Hey everybody! It\'s time for an update from your favorite place to blow money! We have even more ways to blow your money coming up soon! Ever wanted to build a whole block of Amsterdam houses? Now you can! Well... soon.' }
  end
end
