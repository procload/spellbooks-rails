class AddCorrectToAnswers < ActiveRecord::Migration[8.0]
  def change
    add_column :answers, :correct, :boolean
  end
end
