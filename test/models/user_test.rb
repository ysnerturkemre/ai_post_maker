require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires email" do
    user = User.new(password: "password")
    assert_not user.valid?
    assert user.errors[:email].present?
  end

  test "requires password" do
    user = User.new(email: "user@example.com")
    assert_not user.valid?
    assert user.errors[:password].present?
  end
end
