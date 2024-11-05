class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.string :title, null: false
      t.string :subject, null: false
      t.string :grade_level, null: false
      t.string :difficulty, null: false
      t.integer :number_of_questions, null: false, default: 5
      t.text :interests

      t.timestamps
    end
  end
end
