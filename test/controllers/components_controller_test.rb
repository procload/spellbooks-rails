require "test_helper"

class ComponentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      first_name: "Test",
      last_name: "User",
      email_address: "test@example.com",
      password: "password123",
      role: "teacher"
    )
  end

  test "should get index when authenticated" do
    Rails.env.stubs(:development?).returns(true)
    sign_in_as(@user)
    get components_path
    assert_response :success
  end

  test "should redirect to login when not authenticated" do
    get components_path
    assert_redirected_to new_session_path
  end

  test "should redirect to root when not a developer in production" do
    Rails.env.stubs(:development?).returns(false)
    Rails.env.stubs(:production?).returns(true)
    sign_in_as(@user)
    get components_path
    assert_redirected_to root_path
  end

  private

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
