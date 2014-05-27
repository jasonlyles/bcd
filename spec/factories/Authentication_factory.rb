FactoryGirl.define do
  factory :authentication do
    provider "Twitter"
    user_id 1
    uid "12345"
  end
end