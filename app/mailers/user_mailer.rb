class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(
      to: @user.email_address,
      subject: "Welcome to Spellbooks!"
    )
  end

  def student_credentials(user, password)
    @user = user
    @password = password
    
    mail(
      to: @user.email_address,
      subject: "Your Spellbooks Account Details"
    ) do |format|
      format.html
      format.text
    end
  end
end
