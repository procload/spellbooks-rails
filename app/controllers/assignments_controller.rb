require 'ostruct'

class AssignmentsController < ApplicationController
  # Use assignment layout for all actions
  layout 'assignment'
  
  before_action :require_authentication
  before_action :require_teacher, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :assign_students, :download_pdf]

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
    
    ActiveRecord::Base.transaction do
      if @assignment.save
        # Create the association between teacher and assignment
        @assignment.assignment_users.create!(
          user: Current.user,
          role: 'creator'
        )
        
        begin
          # Attempt to broadcast via Turbo Streams
          Turbo::StreamsChannel.broadcast_append_to(
            'assignments',
            target: 'assignments',
            partial: 'assignments/assignment',
            locals: { assignment: @assignment }
          )
          redirect_to @assignment, notice: 'Assignment was successfully created.'
        rescue RedisClient::CannotConnectError => e
          Rails.logger.error "Redis error: #{e.message}"
          # Don't attempt another redirect here
          raise e # Re-raise to be caught by the outer rescue
        end
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    Rails.logger.error "Error creating assignment: #{e.message}"
    # If we haven't rendered or redirected yet, render the new form
    flash.now[:alert] = 'There was an error creating the assignment.'
    render :new, status: :unprocessable_entity unless performed?
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
    
    # Convert student_ids to integers since they'll come as strings from params
    student_ids = student_ids.map(&:to_i)
    
    # Get current student assignments
    current_student_assignments = @assignment.assignment_users.students
    
    # Remove students that were unselected
    current_student_assignments.each do |assignment_user|
      unless student_ids.include?(assignment_user.user_id)
        assignment_user.destroy
      end
    end
    
    # Add newly selected students
    student_ids.each do |student_id|
      @assignment.assignment_users.students.find_or_create_by(
        user_id: student_id,
        role: 'student'
      )
    end
    
    redirect_to @assignment, notice: 'Student assignments have been updated.'
  rescue => e
    Rails.logger.error "Error assigning students: #{e.message}"
    redirect_to @assignment, alert: 'There was an error updating student assignments.'
  end

  def download_pdf
    @assignment = Assignment.find(params[:id])
    @questions = @assignment.questions
    
    respond_to do |format|
      format.pdf do
        if @assignment.cached_pdf.attached?
          # Return the cached PDF
          redirect_to rails_blob_path(@assignment.cached_pdf, disposition: 'attachment')
        else
          # Generate and cache the PDF
          pdf = render_to_string(
            pdf: "assignment_#{@assignment.id}",
            template: 'assignments/show',
            formats: [:pdf],
            layout: 'pdf',
            disposition: 'attachment',
            page_size: 'Letter',
            margin: { top: 20, bottom: 20, left: 20, right: 20 },
            title: @assignment.title
          )
          
          # Store the generated PDF
          @assignment.cached_pdf.attach(
            io: StringIO.new(pdf),
            filename: "assignment_#{@assignment.id}.pdf",
            content_type: 'application/pdf'
          )
          
          send_data pdf, filename: "assignment_#{@assignment.id}.pdf", type: 'application/pdf', disposition: 'attachment'
        end
      end
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
    params.require(:assignment).permit(
      :title, :subject, :grade_level, :difficulty, 
      :number_of_questions, :interests, :published
    )
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