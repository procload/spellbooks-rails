require 'ostruct'

module ComponentsHelper
  def sample_students
    [
      OpenStruct.new(
        id: 1,
        first_name: "Alice",
        last_name: "Anderson",
        email_address: "alice@example.com"
      ),
      OpenStruct.new(
        id: 2,
        first_name: "Bob",
        last_name: "Brown",
        email_address: "bob@example.com"
      ),
      OpenStruct.new(
        id: 3,
        first_name: "Charlie",
        last_name: "Chen",
        email_address: "charlie@example.com"
      ),
      OpenStruct.new(
        id: 4,
        first_name: "Diana",
        last_name: "Davis",
        email_address: "diana@example.com"
      ),
      OpenStruct.new(
        id: 5,
        first_name: "Edward",
        last_name: "Evans",
        email_address: "edward@example.com"
      )
    ]
  end

  def difficulty_options
    [
      { label: 'Easy', value: 'easy', checked: true },
      { label: 'Medium', value: 'medium' },
      { label: 'Hard', value: 'hard' }
    ]
  end

  def subject_options
    [
      { label: 'Math', value: 'Math', checked: true },
      { label: 'Science', value: 'Science' },
      { label: 'English', value: 'English' },
      { label: 'History', value: 'History' },
      { label: 'Art', value: 'Art' }
    ]
  end
end