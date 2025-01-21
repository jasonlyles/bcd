# frozen_string_literal: true

class AddNotesToPartsLists < ActiveRecord::Migration[7.2]
  add_column :parts_lists, :notes, :text
end
