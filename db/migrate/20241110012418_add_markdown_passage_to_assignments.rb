class AddMarkdownPassageToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :markdown_passage, :text
  end
end
