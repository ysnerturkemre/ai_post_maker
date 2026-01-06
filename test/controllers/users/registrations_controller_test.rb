require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "renders sign up page" do
    get new_user_registration_path
    assert_response :success
  end

  test "creates account with valid params" do
    assert_difference -> { User.count }, 1 do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path(locale: I18n.default_locale)
  end

  test "rejects invalid signup" do
    assert_no_difference -> { User.count } do
      post user_registration_path, params: { user: { email: "", password: "" } }
    end

    assert_response :unprocessable_entity
  end
end
