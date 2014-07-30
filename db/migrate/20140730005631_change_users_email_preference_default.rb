class ChangeUsersEmailPreferenceDefault < ActiveRecord::Migration
  def change
    change_column_default(:users, :email_preference, 2)
  end
end
