class AddImagesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :images, :json
  end
end
