class CreateStudentResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :student_responses do |t|
      t.references :question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :answer_text, null: false
      t.boolean :correct, default: false

      t.timestamps
    end

    add_index :student_responses, [:user_id, :question_id], unique: true
  end
end