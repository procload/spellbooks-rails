require "test_helper"

class FactoryTest < ActiveSupport::TestCase
  test "user factory is valid" do
    assert build(:user).valid?
  end

  test "assignment factory is valid" do
    assert build(:assignment).valid?
  end

  test "assignment_user factory is valid" do
    assert build(:assignment_user).valid?
  end
end 