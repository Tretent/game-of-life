require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  def sign_in_as(user, password: "password")
    visit new_session_path
    assert_selector "h2", text: "Sign in"  # Wait for form to load

    fill_in "Email", with: user.email_address
    fill_in "Password", with: password

    click_button "Sign in"

    # Wait for authenticated state - the definitive indicator of successful login
    assert_css "body[data-authenticated='true']", wait: 10
  end
end
