module SegmentedControlHelper
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