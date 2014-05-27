# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :radmin do
    email "secret_agent_man@spy.net"
    password "top_secret"
  end
end
