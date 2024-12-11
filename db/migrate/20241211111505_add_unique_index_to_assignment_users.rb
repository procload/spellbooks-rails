class AddUniqueIndexToAssignmentUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :assignment_users, [:assignment_id, :user_id, :role], if_exists: true
    add_index :assignment_users, [:assignment_id, :user_id, :role], unique: true,
      name: 'index_assignment_users_on_assignment_user_and_role'
  end
end