class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string :name, :limit => 40
      t.string :url, :limit => 40
      t.string :contact, :limit => 40

      t.timestamps
    end
  end

  def self.down
    drop_table :partners
  end
end
