class RemovePartnerStringRestrictions < ActiveRecord::Migration
  def change
    change_column(:partners, :name, :string, limit: 255)
    change_column(:partners, :url, :string, limit: 255)
    change_column(:partners, :contact, :string, limit: 255)
  end
end
