require "test_helper"

class ConfirmationsMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
  end

  test "confirmation email is sent to the user's email address" do
    email = ConfirmationsMailer.confirmation(@user)
    assert_equal [ @user.email_address ], email.to
  end

  test "confirmation email has correct subject" do
    email = ConfirmationsMailer.confirmation(@user)
    assert_equal "Confirm your email", email.subject
  end

  test "confirmation email is sent from the default address" do
    email = ConfirmationsMailer.confirmation(@user)
    assert_equal [ "test@pasqualiroberto.it" ], email.from
  end

  test "confirmation email html body contains confirmation link" do
    email = ConfirmationsMailer.confirmation(@user)
    assert_match %r{/confirmations/}, email.html_part.body.to_s
  end

  test "confirmation email text body contains confirmation link" do
    email = ConfirmationsMailer.confirmation(@user)
    assert_match %r{/confirmations/}, email.text_part.body.to_s
  end

  test "confirmation email body mentions Game of Life" do
    email = ConfirmationsMailer.confirmation(@user)
    assert_match "Game of Life", email.html_part.body.to_s
    assert_match "Game of Life", email.text_part.body.to_s
  end

  test "confirmation email mentions expiration time" do
    email = ConfirmationsMailer.confirmation(@user)
    assert_match "24 hours", email.html_part.body.to_s
    assert_match "24 hours", email.text_part.body.to_s
  end
end
