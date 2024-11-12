class AddColumnsToStudentResponses < ActiveRecord::Migration[7.1]
  def change
    # Add references first
    unless column_exists?(:student_responses, :user_id)
      add_reference :student_responses, :user, null: false, foreign_key: true
    end
    
    unless column_exists?(:student_responses, :question_id)
      add_reference :student_responses, :question, null: false, foreign_key: true
    end

    # Then add other columns
    unless column_exists?(:student_responses, :answer_text)
      add_column :student_responses, :answer_text, :string, null: false
    end
    
    unless column_exists?(:student_responses, :correct)
      add_column :student_responses, :correct, :boolean, default: false
    end
    
    # Finally add the unique index
    unless index_exists?(:student_responses, [:user_id, :question_id])
      add_index :student_responses, [:user_id, :question_id], unique: true
    end
  end
end 