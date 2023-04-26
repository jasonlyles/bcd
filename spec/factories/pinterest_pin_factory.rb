# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :pinterest_pin do
    image_id { 100 }
    pinterest_board_id { 50 }
    pinterest_native_id { '456456456456' }
    link { 'https://google.com' }
    title { 'Just a pin' }
    description { 'Just a description of a pin' }
  end

  factory :pin_with_associations, parent: :pinterest_pin do |pin|
    pin.before(:create) { |_|
      FactoryBot.create(:image, id: 100)
      FactoryBot.create(:pinterest_board, id: 50)
    }
  end
end
