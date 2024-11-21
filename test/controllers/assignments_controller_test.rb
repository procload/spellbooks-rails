require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = User.create!(
      first_name: "Test",
      last_name: "Teacher",
      email_address: "teacher@example.com",
      password: "password123",
      role: "teacher"
    )
    @student = User.create!(
      first_name: "Test",
      last_name: "Student",
      email_address: "student@example.com",
      password: "password123",
      role: "student"
    )
    @assignment = Assignment.create!(
      title: "Test Assignment",
      subject: "Math",
      grade_level: 5,
      difficulty: "Medium",
      number_of_questions: 10,
      interests: "test interests"
    )
    AssignmentUser.create!(user: @teacher, assignment: @assignment, role: 'creator')
  end

  test "should get index when authenticated" do
    sign_in_as(@teacher)
    get assignments_path
    assert_response :success
  end

  test "should redirect to login when not authenticated" do
    get assignments_path
    assert_redirected_to new_session_path
    assert_equal 'Please sign in to continue.', flash[:notice]
  end

  test "should create assignment when authenticated as teacher" do
    sign_in_as(@teacher)
    assert_difference('Assignment.count') do
      post assignments_path, params: {
        assignment: {
          title: "New Test Assignment",
          subject: "Science",
          grade_level: 6,
          difficulty: "Easy",
          number_of_questions: 5,
          interests: "test interests"
        }
      }
    end
    assert_redirected_to root_path
    assert_equal 'Assignment is being generated...', flash[:notice]
  end

  test "should not allow student to create assignment" do
    sign_in_as(@student)
    assert_no_difference('Assignment.count') do
      post assignments_path, params: {
        assignment: {
          title: "New Test Assignment",
          subject: "Science",
          grade_level: 6,
          difficulty: "Easy",
          number_of_questions: 5,
          interests: "test interests"
        }
      }
    end
    assert_redirected_to root_path
    assert_equal 'You must be a teacher to access this area', flash[:alert]
  end

  test "download_pdf serves cached version when available" do
    sign_in_as(@teacher)
    @assignment.cached_pdf.attach(
      io: StringIO.new("fake pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )

    get download_pdf_assignment_path(@assignment, format: :pdf)
    assert_response :redirect
    assert_match /rails\/active_storage\/blobs/, @response.redirect_url
  end

  test "download_pdf generates and caches new PDF when no cache exists" do
    sign_in_as(@teacher)
    assert_not @assignment.cached_pdf.attached?

    get download_pdf_assignment_path(@assignment, format: :pdf)
    assert_response :success
    assert @assignment.reload.cached_pdf.attached?
  end

  private

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
