class RemovePartnerStringRestrictions < ActiveRecord::Migration
  def up
    change_column(:partners, :name, :string, limit: 255)
    change_column(:partners, :url, :string, limit: 255)
    change_column(:partners, :contact, :string, limit: 255)
  end

  def down
    change_column(:partners, :name, :string, limit: 40)
    change_column(:partners, :url, :string, limit: 40)
    change_column(:partners, :contact, :string, limit: 40)
  end
end
