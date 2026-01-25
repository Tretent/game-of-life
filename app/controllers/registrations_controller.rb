class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to registration_path, alert: t("registrations.create.rate_limited") }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      ConfirmationsMailer.confirmation(@user).deliver_later
      redirect_to new_session_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
