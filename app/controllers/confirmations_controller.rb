class ConfirmationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_confirmation_path, alert: "Try again later." }

  def new
  end

  def create
    if (user = User.find_by(email_address: params[:email_address]))
      if user.confirmed?
        redirect_to new_session_path, notice: "Your email is already confirmed. Please sign in."
      else
        ConfirmationsMailer.confirmation(user).deliver_later
        redirect_to new_session_path, notice: "Confirmation instructions sent (if user with that email address exists)."
      end
    else
      redirect_to new_session_path, notice: "Confirmation instructions sent (if user with that email address exists)."
    end
  end

  def show
    user = User.find_by_token_for(:email_confirmation, params[:token])

    if user.nil?
      redirect_to new_confirmation_path, alert: "Confirmation link is invalid or has expired."
    elsif user.confirmed?
      redirect_to new_session_path, notice: "Your email is already confirmed. Please sign in."
    else
      user.confirm!
      start_new_session_for user
      redirect_to root_path, notice: "Your email has been confirmed. Welcome!"
    end
  end
end
