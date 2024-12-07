# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome(User.first || FactoryBot.create(:user))
  end

  def student_credentials
    student = User.students.first || FactoryBot.create(:user, :student)
    UserMailer.student_credentials(student, "preview_password123")
  end
end
