require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_confirmation_path
    assert_response :success
  end

  test "create sends confirmation email" do
    user = User.create!(email_address: "unconfirmed@example.com", password: "password")

    assert_enqueued_email_with ConfirmationsMailer, :confirmation, args: [ user ] do
      post confirmations_path, params: { email_address: user.email_address }
    end

    assert_redirected_to new_session_path
  end

  test "create does not reveal if user exists" do
    post confirmations_path, params: { email_address: "nonexistent@example.com" }

    assert_redirected_to new_session_path
    assert_match /confirmation instructions sent/i, flash[:notice]
  end

  test "show confirms user with valid token" do
    user = User.create!(email_address: "unconfirmed@example.com", password: "password")
    token = user.generate_token_for(:email_confirmation)

    get confirmation_path(token)

    assert_redirected_to root_path
    assert user.reload.confirmed?
    assert cookies[:session_id]
  end

  test "show rejects invalid token" do
    get confirmation_path("invalid_token")

    assert_redirected_to new_confirmation_path
    assert_match /invalid or has expired/i, flash[:alert]
  end

  test "unconfirmed user cannot sign in" do
    user = User.create!(email_address: "unconfirmed@example.com", password: "password")

    post session_path, params: { session: { email_address: user.email_address, password: "password" } }

    assert_redirected_to new_confirmation_path
    assert_nil cookies[:session_id]
  end
end
