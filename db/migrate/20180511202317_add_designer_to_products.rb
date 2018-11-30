class AddDesignerToProducts < ActiveRecord::Migration
  def change
    add_column :products, :designer, :string, default: 'brian_lyles'
  end
end
