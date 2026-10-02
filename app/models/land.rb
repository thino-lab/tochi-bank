# 土地バンクに登録された土地。
# enum の整数値・キーは pg-core properties と一致させる（ラベルは config/locales/enums/ja.yml）。
class Land < ApplicationRecord
  include UlidPk
  include SoftDeletable
  include TenantOwned
  include ManYenAttribute

  TSUBO_PER_SQM = 0.3025 # 1㎡ = 0.3025坪

  man_yen_attribute :price

  belongs_to :in_charge_user, class_name: "Profile", optional: true
  belongs_to :created_by, class_name: "Profile", optional: true
  has_many :land_proposals

  # 土地バンク独自のステータス（pg-core の商談状況とは別管理）
  enum :status, { available: 0, in_negotiation: 1, contracted: 2, draft: 3 }, prefix: true
  enum :zoning, LandEnum::ZONING, prefix: true
  enum :land_category, LandEnum::LAND_CATEGORY, prefix: true
  enum :topography, { flat: 0, high: 1, low: 2, tiered: 3, sloped: 4 }, prefix: true
  enum :current_status, { has_old_house: 0, vacant_land: 1, before_development: 2, vacant: 3, occupied: 4, under_development: 5, others: 6 }, prefix: true

  # お客様に紹介できる状態（公開ページに出してよい土地）
  scope :proposable, -> { active.where(status: [ :available, :in_negotiation ]) }

  validates :name, presence: true
  validates_same_company :in_charge_user, :created_by
  validates :price, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :land_area, numericality: { greater_than: 0 }, allow_nil: true

  before_validation :fill_land_area_tsubo

  def address
    [ prefecture, city, address_detail ].compact_blank.join
  end

  # 坪単価（円）
  def price_per_tsubo
    return nil if price.blank? || land_area_tsubo.to_f <= 0
    (price / land_area_tsubo).round
  end

  # フォームの select 用 [[日本語ラベル, enumキー], ...]
  def self.enum_options(attr)
    defined_enums.fetch(attr.to_s).keys.map do |key|
      [ I18n.t("enums.land.#{attr}.#{key}"), key ]
    end
  end

  private

  # ㎡が入力されていれば坪は自動計算（坪だけ手入力された場合は尊重する）
  def fill_land_area_tsubo
    return if land_area.blank?
    self.land_area_tsubo = (land_area * TSUBO_PER_SQM).round(2) if land_area_changed? || land_area_tsubo.blank?
  end
end
