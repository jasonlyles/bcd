class AddFeaturedFlagToProducts < ActiveRecord::Migration
  def change
    add_column :products, :featured, :boolean, :default => false
  end
end
