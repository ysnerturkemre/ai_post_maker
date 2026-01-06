require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "renders sign in page" do
    get new_user_session_path
    assert_response :success
  end

  test "signs in with valid credentials" do
    user = users(:one)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_response :success
    assert_match(/url=/, response.headers["Refresh"].to_s)
  end

  test "rejects invalid credentials" do
    user = users(:one)

    post user_session_path, params: { user: { email: user.email, password: "wrong" } }

    assert_response :unprocessable_entity
  end
end
