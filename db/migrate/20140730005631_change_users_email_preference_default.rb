class ChangeUsersEmailPreferenceDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:users, :email_preference, 2)
  end
end
