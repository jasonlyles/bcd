class CreateSwitches < ActiveRecord::Migration[4.2]
  def up
    create_table :switches do |t|
      t.string :switch, limit: 30
      t.boolean :switch_on, default: false

      t.timestamps
    end
  end

  def down
    drop_table :switches
  end
end
