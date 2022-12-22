# frozen_string_literal: true

namespace :db do
  task seed_colors: :environment do
    require 'csv'

    puts 'Seeding parts list colors'
    csv_text = File.read(Rails.root.join('lib', 'seeds', 'colors.csv'))
    csv = CSV.parse(csv_text, headers: true, encoding: 'ISO-8859-1')
    csv.each do |row|
      row.each { |item| item[1].gsub!('\N', '') }
      c = Color.new
      c.bl_id = row[1]
      c.ldraw_id = row[2]
      c.lego_id = row[3]
      c.name = row[4]
      c.bl_name = row[5]
      c.lego_name = row[6]
      c.ldraw_rgb = row[7]
      c.rgb = row[8]
      c.save!
    end
    puts "There are now #{Color.count} rows in the colors table"
  end

  task seed_parts: :environment do
    require 'csv'

    puts 'Seeding parts list parts'
    csv_text = File.read(Rails.root.join('lib', 'seeds', 'parts.csv'))
    csv = CSV.parse(csv_text, headers: false, encoding: 'ISO-8859-1')
    csv.each do |row|
      p = Part.new
      p.bl_id = row[0]
      p.ldraw_id = row[1]
      p.name = row[2]
      p.save!
    end
    puts "There are now #{Part.count} rows in the parts table"
  end
end
