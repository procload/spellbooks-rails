require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = create(:user, :teacher)
    @student_params = {
      first_name: "Jane",
      last_name: "Smith",
      email_address: "jane.smith@example.com"
    }
    sign_in_as @teacher
  end

  test "should get index" do
    get students_path
    assert_response :success
  end

  test "should get new" do
    get new_student_path
    assert_response :success
  end

  test "should create student" do
    assert_difference("User.count") do
      assert_enqueued_email_with UserMailer, :student_credentials do
        post students_path, params: { user: @student_params }
      end
    end

    student = User.last
    assert_equal @teacher, student.teacher
    assert_equal 'student', student.role
    assert_redirected_to students_path
  end

  test "non-teachers cannot access student management" do
    sign_in_as create(:user, :student)
    
    get students_path
    assert_redirected_to root_path
    
    get new_student_path
    assert_redirected_to root_path
    
    post students_path, params: { user: @student_params }
    assert_redirected_to root_path
  end

  test "should not create student with invalid params" do
    assert_no_difference("User.count") do
      post students_path, params: { user: @student_params.merge(email_address: '') }
    end

    assert_response :unprocessable_entity
  end

  test "teachers can only see their own students" do
    other_teacher = create(:user, :teacher)
    other_student = create(:user, :student, teacher: other_teacher)
    my_student = create(:user, :student, teacher: @teacher)

    get students_path
    
    assert_response :success
    assert_select "td", text: my_student.email_address
    assert_select "td", text: other_student.email_address, count: 0
  end
end 