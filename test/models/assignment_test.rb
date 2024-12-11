require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @assignment = create(:assignment)
    create(:assignment_user, user: @teacher, assignment: @assignment, role: 'creator')
  end

  test "can create assignment with valid attributes" do
    assignment = build(:assignment)
    assert assignment.valid?
  end

  test "cannot create assignment without title" do
    assignment = build(:assignment, title: nil)
    assert_not assignment.valid?
    assert_includes assignment.errors[:title], "can't be blank"
  end

  test "assignment belongs to teacher through assignment_users" do
    assert_includes @assignment.teachers, @teacher
  end
end
