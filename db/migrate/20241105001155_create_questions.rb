class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.text :content
      t.string :correct_answer
      t.text :explanation
      t.text :options
      t.text :passage

      t.timestamps
    end
  end
end
