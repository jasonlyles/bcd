# frozen_string_literal: true

class CreateFeatures < ActiveRecord::Migration[7.2]
  def change
    create_table :features do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.boolean :enabled, default: false

      t.timestamps
    end

    add_index :features, :name, unique: true
  end
end
