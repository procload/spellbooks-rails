class UsersController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    # Allow only teachers to sign up through this action
    if @user.role != 'teacher'
      redirect_to new_session_path, alert: 'Only teachers can create accounts directly.'
      return
    end
    
    if @user.save
      # Send welcome email
      UserMailer.welcome(@user).deliver_later
      
      # Start a session for the new user
      start_new_session_for @user
      redirect_to after_authentication_url, notice: 'Welcome! Your account has been created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    
    if @user.update(user_params)
      redirect_to edit_user_path, notice: 'Your profile has been updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new_student
    @student = User.new
  end

  def create_student
    @student = Current.user.students.build(student_params)
    @student.role = 'student'
    
    if @student.save
      redirect_to students_path, notice: 'Student account has been created.'
    else
      render :new_student, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, 
      :last_name, 
      :email_address, 
      :password, 
      :password_confirmation,
      :role,
      :profile_picture
    )
  end

  def student_params
    params.require(:user).permit(
      :first_name, 
      :last_name, 
      :email_address, 
      :password, 
      :password_confirmation,
      :profile_picture
    )
  end
end 