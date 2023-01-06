class AddFeaturedFlagToProducts < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :featured, :boolean, default: false
  end
end
