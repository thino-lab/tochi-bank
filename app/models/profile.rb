# スタッフ（ログインユーザー）
class Profile < ApplicationRecord
  include UlidPk
  include SoftDeletable
  include TenantOwned

  has_secure_password

  enum :role, { admin: 0, member: 1 }, prefix: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
