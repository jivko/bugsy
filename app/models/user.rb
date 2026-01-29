class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :owned_projects, class_name: "Project", foreign_key: :owner_id, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships

  enum :role, { member: 0, admin: 1 }, default: :member

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 5 }, if: -> { new_record? || password.present? }

  def display_name
    name.presence || email_address
  end
end
