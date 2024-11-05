class AddPassageToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :passage, :text
  end
end
