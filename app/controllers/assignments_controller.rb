require 'ostruct'

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :assign_students]
  before_action :require_teacher, only: [:new, :create, :edit, :update, :destroy, :assign_students]

  def index
    @assignments = if Current.user.teacher?
      Assignment.joins(:assignment_users)
                .where(assignment_users: { user_id: Current.user.id, role: 'creator' })
                .distinct
    else
      Assignment.joins(:assignment_users)
                .where(assignment_users: { user_id: Current.user.id, role: 'student' })
                .distinct
    end
  end

  def show
    @questions = @assignment.questions
    @students = User.students if Current.user.teacher?
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)

    if @assignment.save
      # Create the teacher-assignment relationship
      @assignment.assignment_users.create(user: Current.user, role: 'creator')
      redirect_to root_path, notice: "Assignment was successfully created. Processing has begun."
    else
      render :new, status: :unprocessable_entity
    end
  rescue Redis::CannotConnectError => e
    Rails.logger.error "Redis Connection Error: #{e.message}"
    flash.now[:alert] = "Service temporarily unavailable. Please try again later."
    render :new, status: :service_unavailable
  end

  def edit
    unless @assignment.teachers.include?(Current.user)
      redirect_to root_path, alert: "You can only edit assignments you created"
    end
  end

  def update
    unless @assignment.teachers.include?(Current.user)
      redirect_to root_path, alert: "You can only edit assignments you created"
      return
    end

    if @assignment.update(assignment_params)
      redirect_to @assignment, notice: 'Assignment was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # New action for assigning students to an assignment
  def assign_students
    student_ids = params[:student_ids] || []
    
    if @assignment.assign_to_students(student_ids, Current.user)
      redirect_to @assignment, notice: 'Students successfully assigned to this assignment.'
    else
      redirect_to @assignment, alert: 'There was an error assigning students.'
    end
  end

  def destroy
    unless @assignment.teachers.include?(Current.user)
      redirect_to root_path, alert: "You can only delete assignments you created"
      return
    end

    if @assignment.destroy
      redirect_to assignments_path, notice: 'Assignment was successfully deleted.'
    else
      redirect_to @assignment, alert: 'There was an error deleting this assignment.'
    end
  end

  private

  def set_assignment
    @assignment = Assignment.find(params[:id])
    unless @assignment.users.include?(Current.user)
      redirect_to root_path, alert: "You don't have access to this assignment"
    end
  end

  def assignment_params
    params.require(:assignment).permit(:title, :subject, :grade_level, :difficulty, 
                                     :number_of_questions, :interests)
  end

  def generate_prompt(assignment)
    Rails.logger.info "Generating prompt for subject: #{assignment.subject}"
    
    prompt_filename = PromptMapperService.get_prompt_filename(assignment.subject)
    Rails.logger.info "Mapped to prompt file: #{prompt_filename}"
    
    template_path = Rails.root.join('lib', 'prompts', prompt_filename)
    Rails.logger.info "Looking for template at: #{template_path}"
    
    if File.exist?(template_path)
      template = File.read(template_path)
      Rails.logger.info "Found template, length: #{template.length} characters"
      
      # Create a binding where 'assignment' is available
      b = binding
      b.local_variable_set(:assignment, assignment)
      
      prompt = ERB.new(template).result(b)
      Rails.logger.info "Generated prompt, length: #{prompt.length} characters"
      Rails.logger.debug "Full prompt content: #{prompt}"
      prompt
    else
      Rails.logger.warn "No prompt template found for subject: #{assignment.subject}"
      fallback = """
        Create an educational assignment with the following parameters:
        Title: #{assignment.title}
        Subject: #{assignment.subject}
        Grade Level: #{assignment.grade_level}
        Difficulty: #{assignment.difficulty}
        Number of Questions: #{assignment.number_of_questions}
        Student Interests: #{assignment.interests}
      """
      Rails.logger.info "Using fallback prompt"
      Rails.logger.debug "Fallback prompt content: #{fallback}"
      fallback
    end
  end
end