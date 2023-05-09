class AddBricklinkStateToParts < ActiveRecord::Migration[7.0]
  def change
    add_column :parts, :bricklink_state, :integer, default: 0
  end
end
