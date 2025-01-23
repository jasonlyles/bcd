FactoryBot.define do
  factory :setting do
    name { 'default_discount_percentage' }
    description { 'The default discount percentage a model is set to when featuring it.' }
    value { '25.0' }
  end
end
