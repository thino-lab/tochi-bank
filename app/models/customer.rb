# 土地を紹介するお客様
class Customer < ApplicationRecord
  include UlidPk
  include SoftDeletable
  include TenantOwned
  include ManYenAttribute

  PORTAL_PURPOSE = :customer_portal

  man_yen_attribute :budget_max

  belongs_to :in_charge_user, class_name: "Profile", optional: true
  has_many :land_proposals
  has_many :proposed_lands, through: :land_proposals, source: :land

  validates :name, presence: true
  validates_same_company :in_charge_user
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # お客様専用ページのトークン。ID を直接晒さず、改ざん・総当たりもできない（SUGOSEKI の公開物件と同方式）
  def portal_token
    signed_id(purpose: PORTAL_PURPOSE)
  end

  def self.find_by_portal_token(token)
    find_signed(token, purpose: PORTAL_PURPOSE)
  end
end
