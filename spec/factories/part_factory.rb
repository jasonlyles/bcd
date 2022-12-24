# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :part do
    bl_id { '1' }
    ldraw_id { '1' }
    lego_id { '1' }
    name { 'Brick' }
    check_bricklink { true }
    check_rebrickable { true }
    alternate_nos { '' }
    is_obsolete { false }
    year_from { '1996' }
    year_to { '2018' }
    brickowl_ids { '' }
    is_lsynth { false }
  end
end
