class ChangeInterestsToText < ActiveRecord::Migration[8.0]
  def up
    change_column :assignments, :interests, :text
  end

  def down
    change_column :assignments, :interests, :string, array: true, default: []
  end
end 