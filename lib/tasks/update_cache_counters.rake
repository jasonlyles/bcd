# frozen_string_literal: true

task update_cache_counters: :environment do
  puts 'Updating parts_lists'
  PartsList.find_each do |parts_list|
    PartsList.reset_counters(parts_list.id, :lots)
  end
end
