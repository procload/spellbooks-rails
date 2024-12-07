class StudentsController < ApplicationController
  before_action :require_teacher
  
  def index
    @students = Current.user.students
  end

  def new
    @student = User.new
  end

  def create
    @student = Current.user.students.build(student_params)
    @student.role = 'student'
    password = SecureRandom.hex(8) # Generate a random password
    @student.password = password
    
    if @student.save
      # Send credentials to the student
      UserMailer.student_credentials(@student, password).deliver_later
      redirect_to students_path, notice: 'Student account has been created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def student_params
    params.require(:user).permit(:first_name, :last_name, :email_address)
  end
end 