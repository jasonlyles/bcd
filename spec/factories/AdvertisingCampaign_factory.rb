# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :advertising_campaign do
    partner_id 1
    reference_code "123456789A"
    description "Sweet campaign that's making us millions"
    campaign_live 't'
  end

  factory :advertising_campaign_with_partner, :parent => :advertising_campaign do |advertising_campaign|
    advertising_campaign.after(:create){ |partner| FactoryGirl.create(:partner, :advertising_campaign => partner) }
  end
  #factory :advertising_campaign_with_partner do
  #  after(:create) do |advertising_campaign,evaluator|
  #    FactoryGirl.create_list(:partner, 1, advertising_campaign: :partner)
  #  end
  #end
end
