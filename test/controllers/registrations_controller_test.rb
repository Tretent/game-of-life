require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated users may load new" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("User.count", 1) do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to new_session_path
    assert_match /Please check your email to confirm your account./i, flash[:notice]

    user = User.find_by(email_address: "newuser@example.com")
    assert_not user.confirmed?
  end

  test "create sends confirmation email" do
    assert_enqueued_emails 1 do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
  end

  test "create with invalid params" do
    assert_no_difference("User.count") do
      post registration_path, params: {
        user: {
          email_address: "",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with mismatched passwords" do
    assert_no_difference("User.count") do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with duplicate email" do
    existing_user = users(:one)

    assert_no_difference("User.count") do
      post registration_path, params: {
        user: {
          email_address: existing_user.email_address,
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
