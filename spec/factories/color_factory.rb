# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :color do
    bl_id { '2' }
    ldraw_id { '0' }
    lego_id { '11' }
    name { 'Black' }
    bl_name { 'Black' }
    lego_name { 'Black' }
    ldraw_rgb { '212121' }
    rgb { '1B2A34' }
  end
end
