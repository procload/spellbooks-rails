require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @student = create(:user, :student)
    @assignment = create(:assignment)
    create(:assignment_user, user: @teacher, assignment: @assignment, role: 'creator')
    
    # Set up teacher-student relationship
    @teacher.students << @student
  end

  ### Validation Tests ###
  
  test "can create assignment with valid attributes" do
    assignment = build(:assignment)
    assert assignment.valid?
  end

  test "cannot create assignment without title" do
    assignment = build(:assignment, title: nil)
    assert_not assignment.valid?
    assert_includes assignment.errors[:title], "can't be blank"
  end

  test "cannot create assignment with invalid grade level" do
    assignment = build(:assignment, grade_level: '13')
    assert_not assignment.valid?
    assert_includes assignment.errors[:grade_level], "must be less than or equal to 12"
  end

  test "cannot create assignment with invalid difficulty" do
    assignment = build(:assignment, difficulty: 'Super Hard')
    assert_not assignment.valid?
    assert_includes assignment.errors[:difficulty], "is not included in the list"
  end

  test "number_of_questions must be positive" do
    assignment = build(:assignment, number_of_questions: 0)
    assert_not assignment.valid?
    assert_includes assignment.errors[:number_of_questions], "must be greater than 0"
  end

  ### Association Tests ###

  test "assignment belongs to teacher through assignment_users" do
    assert_includes @assignment.teachers, @teacher
  end

  test "can assign students to assignment" do
    assert_difference -> { @assignment.assignment_users.students.count } do
      @assignment.assign_to_students([@student.id], @teacher)
    end
    assert_includes @assignment.students, @student
  end

  test "cannot assign students if not teacher" do
    non_teacher = create(:user, :student)
    assert_no_difference -> { @assignment.students.count } do
      @assignment.assign_to_students([@student.id], non_teacher)
    end
  end

  ### Status Tests ###

  test "new assignment has pending status" do
    assignment = create(:assignment)
    assert_equal 'pending', assignment.status
  end

  test "can enqueue assignment for processing" do
    assert @assignment.enqueue_processing
    assert_equal 'in_progress', @assignment.reload.status
  end

  test "cannot enqueue non-pending assignment" do
    @assignment.update!(status: 'completed')
    assert_not @assignment.enqueue_processing
  end

  ### Student Progress Tests ###

  test "can track student progress" do
    # Assign student to assignment
    @assignment.assign_to_students([@student.id], @teacher)
    
    # Create a question with answers using skip_validations
    question = create(:question, :skip_validations, assignment: @assignment)
    
    # Add answers after question creation
    correct_answer = create(:answer, question: question, text: "Correct Answer", is_correct: true)
    wrong_answer = create(:answer, question: question, text: "Wrong Answer", is_correct: false)
    
    # Create student answer
    assignment_user = @assignment.assignment_users.find_by(user: @student)
    create(:student_answer, 
           question: question, 
           assignment_user: assignment_user, 
           correct: true,
           answer: correct_answer.text)
    
    progress = @assignment.student_progress(@student)
    
    assert_equal assignment_user.status, progress[:status]
    assert_equal 1, progress[:answered_questions]
    assert_equal 1, progress[:total_questions]
    assert_equal 1, progress[:correct_answers]
  end

  test "returns nil progress for non-assigned student" do
    assert_nil @assignment.student_progress(@student)
  end
end
