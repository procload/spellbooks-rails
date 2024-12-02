# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome(User.first || User.new(
      first_name: "Test",
      last_name: "User",
      email_address: "test@example.com"
    ))
  end
end
