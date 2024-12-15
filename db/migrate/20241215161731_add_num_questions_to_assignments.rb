class AddNumQuestionsToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :num_questions, :integer, default: 3, null: false
  end
end
