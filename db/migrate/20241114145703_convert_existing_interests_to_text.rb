class ConvertExistingInterestsToText < ActiveRecord::Migration[8.0]
  def up
    Assignment.find_each do |assignment|
      if assignment.interests.is_a?(Array)
        assignment.update_column(:interests, assignment.interests.join(", "))
      end
    end
  end
end 