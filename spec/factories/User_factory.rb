# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "charlie_brown@peanuts.com"
    password "secret"
    tos_accepted "1"
  end
end
