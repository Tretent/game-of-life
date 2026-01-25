class ConfirmationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_confirmation_path, alert: t("confirmations.create.rate_limited") }

  def new
  end

  def create
    if (user = User.find_by(email_address: confirmation_params[:email_address]))
      if user.confirmed?
        redirect_to new_session_path, notice: t(".already_confirmed")
      else
        ConfirmationsMailer.confirmation(user).deliver_later
        redirect_to new_session_path, notice: t(".success")
      end
    else
      redirect_to new_session_path, notice: t(".success")
    end
  end

  def show
    user = User.find_by_token_for(:email_confirmation, params[:token])

    if user.nil?
      redirect_to new_confirmation_path, alert: t(".invalid_token")
    elsif user.confirmed?
      redirect_to new_session_path, notice: t("confirmations.create.already_confirmed")
    else
      user.confirm!
      start_new_session_for user
      redirect_to root_path, notice: t(".success")
    end
  end

  private

  def confirmation_params
    params.expect(confirmation: [ :email_address ])
  end
end
