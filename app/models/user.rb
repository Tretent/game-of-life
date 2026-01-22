class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :games, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true

  generates_token_for :email_confirmation, expires_in: 24.hours do
    confirmed_at
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current)
  end
end
