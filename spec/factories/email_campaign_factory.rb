# Read about factories at http://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :email_campaign do
    description "MyText"
    subject "Sweet Email"
    click_throughs 1
  end
end
