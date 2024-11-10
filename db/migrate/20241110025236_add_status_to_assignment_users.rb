class AddStatusToAssignmentUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :assignment_users, :status, :string
  end
end
