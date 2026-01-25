class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :games, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true

  CONFIRMATION_TOKEN_EXPIRY = 24.hours

  generates_token_for :email_confirmation, expires_in: CONFIRMATION_TOKEN_EXPIRY do
    confirmed_at
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current)
  end

  def confirmation_token_expires_in
    CONFIRMATION_TOKEN_EXPIRY
  end
end
