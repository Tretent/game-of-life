require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  def sign_in_as(user, password: "password")
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: password
    click_button "Sign in"
    # Wait for redirect away from login page (handles Turbo timing)
    assert_no_selector "h2", text: "Sign in"
    assert_css "body[data-authenticated='true']"
  end
end
