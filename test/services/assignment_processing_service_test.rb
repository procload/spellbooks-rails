require "test_helper"

class AssignmentProcessingServiceTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @assignment = create(:assignment,
      title: "Test Assignment",
      subject: "Math",
      grade_level: "5",
      difficulty: "Medium",
      number_of_questions: 2,
      interests: "basic arithmetic",
      status: 'in_progress'
    )
    create(:assignment_user, user: @teacher, assignment: @assignment, role: 'creator')

    # Mock LLM responses
    @mock_questions = [
      {
        content: "What is 2 + 2?",
        explanation: "Adding 2 to itself equals 4",
        answers: [
          { text: "4", is_correct: true },
          { text: "3", is_correct: false },
          { text: "5", is_correct: false },
          { text: "2", is_correct: false }
        ]
      },
      {
        content: "What is 3 x 3?",
        explanation: "Multiplying 3 by itself equals 9",
        answers: [
          { text: "9", is_correct: true },
          { text: "6", is_correct: false },
          { text: "12", is_correct: false },
          { text: "3", is_correct: false }
        ]
      }
    ]

    # Stub LlmService class method
    ::LLM::Service.stubs(:generate_questions).returns(@mock_questions)
  end

  test "processes assignment and generates questions" do
    service = AssignmentProcessingService.new(@assignment)
    result = service.execute
    
    assert result.success?
    assert_equal 'completed', @assignment.reload.status
    assert_equal 2, @assignment.questions.count
    
    # Verify questions have proper structure
    @assignment.questions.each do |question|
      assert question.content.present?
      assert question.explanation.present?
      assert_equal 4, question.answers.count
      assert_equal 1, question.answers.where(is_correct: true).count
    end
  end

  test "validates assignment state" do
    @assignment.update!(status: 'pending')
    service = AssignmentProcessingService.new(@assignment)
    result = service.execute
    
    assert_not result.success?
    assert_equal "Assignment must be in 'in_progress' status to be processed", result.error
  end

  test "handles validation errors in questions" do
    ::LLM::Service.stubs(:generate_questions).returns([
      {
        content: '',  # Invalid - blank content
        explanation: 'test',
        answers: [
          { text: "Yes", is_correct: true },
          { text: "No", is_correct: false }
        ]
      }
    ])
    
    service = AssignmentProcessingService.new(@assignment)
    result = service.execute
    assert_not result.success?
    assert_includes result.error, "Content can't be blank"
    assert_equal 'pending', @assignment.reload.status
  end

  test "handles LLM API errors gracefully" do
    ::LLM::Service.stubs(:generate_questions).raises(StandardError.new("LLM API Error"))
    service = AssignmentProcessingService.new(@assignment)
    
    result = service.execute
    assert_not result.success?
    assert_equal "Failed to generate questions: LLM API Error", result.error
    assert_equal 'pending', @assignment.reload.status
  end

  test "preserves existing questions on failure" do
    # Create a valid question with answers
    question = create(:question, :skip_validations, assignment: @assignment)
    create(:answer, question: question, text: "Yes", is_correct: true)
    create(:answer, question: question, text: "No", is_correct: false)
    
    ::LLM::Service.stubs(:generate_questions).raises(StandardError.new("LLM API Error"))
    service = AssignmentProcessingService.new(@assignment)
    
    result = service.execute
    assert_not result.success?
    assert_equal [question], @assignment.reload.questions.to_a
  end
end
