FactoryBot.define do
  factory :third_party_receipt do
    source { 'etsy' }
    third_party_receipt_identifier { 'abcd1234' }
    third_party_order_status { 'Completed' }
    third_party_is_paid { true }
    raw_response_body { '' }
  end
end
