class AssignmentCreationService
  Result = Struct.new(:success?, :assignment, :errors, keyword_init: true)

  def initialize(params, user)
    @params = params
    @user = user
    @errors = {}
  end

  def execute
    return failure_result("Only teachers can create assignments") unless @user.teacher?

    Assignment.transaction do
      create_assignment
      create_assignment_user
      enqueue_processing
      
      success_result
    end
  rescue ActiveRecord::RecordInvalid => e
    failure_result(e.record.errors.messages)
  rescue StandardError => e
    Rails.logger.error "[AssignmentCreationService] Error creating assignment: #{e.message}"
    failure_result("An unexpected error occurred")
  end

  private

  def create_assignment
    @assignment = Assignment.new(@params)
    @assignment.status = 'pending'
    @assignment.save!
  end

  def create_assignment_user
    @assignment.assignment_users.create!(
      user: @user,
      role: 'creator'
    )
  end

  def enqueue_processing
    @assignment.enqueue_processing
  end

  def success_result
    Result.new(
      success?: true,
      assignment: @assignment,
      errors: {}
    )
  end

  def failure_result(errors)
    Result.new(
      success?: false,
      assignment: @assignment,
      errors: errors.is_a?(String) ? { base: [errors] } : errors
    )
  end
end
