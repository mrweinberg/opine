# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :omniauthable,
         omniauth_providers: [ :google_oauth2 ]

  enum :role, { user: 0, admin: 1, superadmin: 2 }, default: :user

  has_many :items, foreign_key: :created_by_user_id, dependent: :nullify, inverse_of: :created_by_user
  has_one_attached :avatar

  validates :username, presence: true, uniqueness: true,
            length: { in: 3..20 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }
  validates :bio, length: { maximum: 500 }
  validates :display_name, length: { maximum: 100 }, allow_blank: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.display_name = auth.info.name
      # Username will be set in complete_profile flow
      user.username = "user_#{SecureRandom.hex(4)}"
    end
  end

  def admin_or_above?
    admin? || superadmin?
  end
end
