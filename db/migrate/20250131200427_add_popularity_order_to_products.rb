# frozen_string_literal: true

class AddPopularityOrderToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :popularity_order, :integer, default: nil
  end
end
