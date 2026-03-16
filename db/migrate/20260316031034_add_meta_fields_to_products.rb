# frozen_string_literal: true

class AddMetaFieldsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :meta_description, :text, default: nil
    add_column :products, :meta_keywords, :text, default: nil
  end
end
