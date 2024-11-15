class AddPublishedToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :published, :boolean, default: false, null: false
    add_index :assignments, :published
  end
end
