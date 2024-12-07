require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = create(:user)
    email = UserMailer.welcome(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["no-reply@example.com"], email.from
    assert_equal [user.email_address], email.to
    assert_equal "Welcome to Spellbooks!", email.subject
  end

  test "student_credentials" do
    student = create(:user, :student)
    password = "testpassword123"
    email = UserMailer.student_credentials(student, password)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["no-reply@example.com"], email.from
    assert_equal [student.email_address], email.to
    assert_equal "Your Spellbooks Account Details", email.subject
    assert_includes email.body.to_s, password
  end
end
