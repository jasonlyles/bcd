class AddProcessingColumnsToModelsWithMountedUploaders < ActiveRecord::Migration
  def change
    add_column :categories, :image_processing, :boolean, :default => false
    add_column :images, :url_processing, :boolean, :default => false
    add_column :parts_lists, :name_processing, :boolean, :default => false
    add_column :products, :pdf_processing, :boolean, :default => false
    add_column :product_types, :image_processing, :boolean, :default => false
    add_column :updates, :image_processing, :boolean, :default => false
  end
end
