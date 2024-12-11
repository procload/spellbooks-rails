class CreateStudentAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :student_answers do |t|
      t.references :assignment_user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :answer
      t.boolean :correct, default: false

      t.timestamps
    end

    add_index :student_answers, [:assignment_user_id, :question_id], unique: true
  end
end