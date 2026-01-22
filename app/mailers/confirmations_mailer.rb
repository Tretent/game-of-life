class ConfirmationsMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    mail subject: "Confirm your email", to: user.email_address
  end
end
