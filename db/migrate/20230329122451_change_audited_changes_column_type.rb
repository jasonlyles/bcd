class ChangeAuditedChangesColumnType < ActiveRecord::Migration[7.0]
  def up
    change_column :audits, :audited_changes, :jsonb, using: 'audited_changes::jsonb'
  end

  def down
    change_column :audits, :audited_changes, :text
  end
end
