class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.string :title
      t.string :subject
      t.integer :grade_level
      t.string :difficulty
      t.integer :number_of_questions
      t.text :interests

      t.timestamps
    end
  end
end
