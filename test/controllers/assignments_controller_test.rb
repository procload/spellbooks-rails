require "test_helper"

class AssignmentsControllerTest < ActionController::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @assignment = create(:assignment, :with_creator, user: @teacher)
  end

  test "should get index when authenticated" do
    session[:session_id] = @teacher.sessions.create!(
      user_agent: 'Rails Testing',
      ip_address: '0.0.0.0'
    ).id

    get :index
    assert_response :success
  end

  test "should redirect to login when not authenticated" do
    get :index
    assert_redirected_to new_session_path
    assert_equal 'Please sign in to continue.', flash[:notice]
  end

  test "should create assignment when authenticated as teacher" do
    session[:session_id] = @teacher.sessions.create!(
      user_agent: 'Rails Testing',
      ip_address: '0.0.0.0'
    ).id

    assert_difference('Assignment.count') do
      post :create, params: { 
        assignment: { 
          title: "New Assignment",
          subject: "Mathematics",
          grade_level: 5,
          difficulty: "Medium",
          number_of_questions: 10,
          interests: "algebra"
        } 
      }
    end

    assert_redirected_to root_path
    assert_includes Assignment.last.teachers, @teacher
  end

  test "should not allow student to create assignment" do
    student = create(:user, :student)
    session[:session_id] = student.sessions.create!(
      user_agent: 'Rails Testing',
      ip_address: '0.0.0.0'
    ).id

    assert_no_difference('Assignment.count') do
      post :create, params: { 
        assignment: { 
          title: "New Assignment",
          subject: "Mathematics",
          grade_level: 5,
          difficulty: "Medium",
          number_of_questions: 10,
          interests: ["algebra"]
        } 
      }
    end

    assert_redirected_to root_path
    assert_equal 'You must be a teacher to access this area', flash[:alert]
  end
end
