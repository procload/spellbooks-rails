class PasswordsController < ApplicationController
  allow_unauthenticated_access only: [:new, :create, :edit, :update]

  def new
  end

  def create
    if @user = User.find_by(email_address: params[:email_address])
      @user.generate_password_reset_token
      PasswordsMailer.reset(@user).deliver_later
    end

    redirect_to root_path, notice: 'Check your email for password reset instructions'
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:token])
    
    if @user.password_reset_sent_at < 15.minutes.ago
      redirect_to new_password_path, alert: 'Password reset has expired'
    end
  end

  def update
    @user = User.find_by_password_reset_token!(params[:token])
    
    if @user.password_reset_sent_at < 15.minutes.ago
      redirect_to new_password_path, alert: 'Password reset has expired'
    elsif @user.update(user_params)
      redirect_to new_session_path, notice: 'Password has been reset. Please sign in with your new password.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
