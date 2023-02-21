# frozen_string_literal: true

require 'docx'

task import_ebay_emails: :environment do
  # Create a Docx::Document object for our existing docx file
  doc = Docx::Document.open("#{Rails.root}/bcd_emails.docx")

  cells = []
  # Iterate through tables
  doc.tables.each do |table|
    # Then iterate through rows
    table.rows.each do |row|
      # And then iterate through cells
      row.cells.each do |cell|
        cells << cell.text
      end
    end
  end

  email_addresses = []
  cells.each do |cell|
    # This regex is taken from URI::MailTo::EMAIL_REGEXP and modified slightly for
    # scanning instead of matching a whole string
    email_addresses << cell.scan(/[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*/)
  end

  email_addresses.flatten!
  email_addresses.map!(&:downcase)
  email_addresses.uniq!

  email_addresses.each_with_index do |email, i|
    puts "Working #{i}"
    # I expect there could be some emails in here for people who ended up buying
    # through the website at some point, so let's just ignore any that fail validation
    # because it's only going to be due to dupe email addresses.
    Guest.create(email:, source: 1, email_preference: 0, skip_tos_accepted: true)
  end
end
