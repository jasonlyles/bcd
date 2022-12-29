class CreateBackendNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :backend_notifications do |t|
      t.text :message
      t.references :dismissed_by, index: true, belongs_to: :radmin

      t.timestamps
    end
  end
end
