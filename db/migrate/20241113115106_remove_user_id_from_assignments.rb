class RemoveUserIdFromAssignments < ActiveRecord::Migration[8.0]
  def change
    remove_column :assignments, :user_id, :integer
  end
end
