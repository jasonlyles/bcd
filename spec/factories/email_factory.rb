FactoryBot.define do
  factory :email do
    name { 'Jim Bob' }
    body { 'Hey ya\'ll. I like the Legos' }
    email_address { 'jimbob@legolover.org' }
  end
end
