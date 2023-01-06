class AddDesignerToProducts < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :designer, :string, default: 'brian_lyles'
  end
end
