# 土地の紹介（お客様 × 土地）と、お客様の反応
class LandProposal < ApplicationRecord
  include UlidPk
  include SoftDeletable
  include TenantOwned

  belongs_to :customer
  belongs_to :land
  belongs_to :proposed_by, class_name: "Profile", optional: true

  enum :reaction, { unread: 0, viewed: 1, interested: 2, declined: 3 }, prefix: true

  validates :land_id, uniqueness: { scope: :customer_id }
  validate :same_company

  private

  def same_company
    return if customer.nil? || land.nil?
    errors.add(:base, "別企業の顧客・土地は紐づけられません") if [ customer.company_id, land.company_id ].uniq != [ company_id ]
  end
end
