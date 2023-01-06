class DropCarrierwaveBackgrounderProcessingColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :categories, :image_processing
    remove_column :images, :url_processing
    remove_column :parts_lists, :name_processing
    remove_column :products, :pdf_processing
    remove_column :product_types, :image_processing
    remove_column :updates, :image_processing
    remove_column :email_campaigns, :image_processing
    remove_column :elements, :image_processing
  end
end
