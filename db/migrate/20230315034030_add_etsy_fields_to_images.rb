class AddEtsyFieldsToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :etsy_listing_image_id, :string
    add_column :images, :position, :integer
    Product.all.each do |product|
      product.images.order(:created_at).each.with_index(1) do |image, index|
        image.update_column :position, index
      end
    end
  end
end
