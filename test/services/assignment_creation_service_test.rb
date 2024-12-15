require "test_helper"

class AssignmentCreationServiceTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @valid_params = {
      title: "Test Assignment",
      subject: "Math",
      grade_level: "5",
      difficulty: "Medium",
      number_of_questions: 10,
      interests: "test interests"
    }
  end

  test "creates assignment with valid params" do
    service = AssignmentCreationService.new(@valid_params, @teacher)
    
    assert_difference ['Assignment.count', 'AssignmentUser.count'] do
      result = service.execute
      assert result.success?
      assert_equal 'in_progress', result.assignment.status
      assert_includes result.assignment.teachers, @teacher
    end
  end

  test "fails with invalid params" do
    invalid_params = @valid_params.merge(title: '')
    service = AssignmentCreationService.new(invalid_params, @teacher)
    
    assert_no_difference ['Assignment.count', 'AssignmentUser.count'] do
      result = service.execute
      assert_not result.success?
      assert_includes result.errors[:title], "can't be blank"
    end
  end

  test "creates assignment with correct associations" do
    service = AssignmentCreationService.new(@valid_params, @teacher)
    result = service.execute
    
    assert result.success?
    assignment = result.assignment
    
    assert_equal @teacher, assignment.teachers.first
    assert_equal 'creator', assignment.assignment_users.first.role
    assert_equal 'in_progress', assignment.status
  end

  test "enqueues processing after creation" do
    service = AssignmentCreationService.new(@valid_params, @teacher)
    result = service.execute
    
    assert result.success?
    assert_equal 'in_progress', result.assignment.reload.status
  end

  test "fails if user is not a teacher" do
    student = create(:user, :student)
    service = AssignmentCreationService.new(@valid_params, student)
    
    assert_no_difference ['Assignment.count', 'AssignmentUser.count'] do
      result = service.execute
      assert_not result.success?
      assert_includes result.errors[:base], "Only teachers can create assignments"
    end
  end
end
