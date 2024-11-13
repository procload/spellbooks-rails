class AddUserIdToAssignments < ActiveRecord::Migration[8.0]
  def up
    # First add the column as nullable
    add_reference :assignments, :user, null: true, foreign_key: true
    
    # Get the first user (or create one if none exists)
    user = User.first || User.create!(
      email_address: 'admin@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
    
    # Associate all existing assignments with this user
    Assignment.update_all(user_id: user.id)
    
    # Now make the column non-nullable
    change_column_null :assignments, :user_id, false
  end

  def down
    remove_reference :assignments, :user
  end
end