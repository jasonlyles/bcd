# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :settings do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.text :value, null: false

      t.timestamps
    end

    add_index :settings, :name, unique: true
  end
end
