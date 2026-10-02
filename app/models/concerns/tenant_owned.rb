# 企業（テナント）に属する業務データの共通実装。
# 全業務テーブルは company_id を持ち、Controller では必ず policy_scope 経由で current_company に絞る。
module TenantOwned
  extend ActiveSupport::Concern

  included do
    belongs_to :company
    scope :of_company, ->(company) { where(company_id: company.id) }
  end

  class_methods do
    # 関連先（担当者など）が同じ企業のものかを検証する。フォームから他社のIDを送られても紐づけない。
    #   validates_same_company :in_charge_user
    def validates_same_company(*associations)
      validate do
        associations.each do |name|
          other = public_send(name)
          errors.add(name, "は同じ企業のものを選択してください") if other && other.company_id != company_id
        end
      end
    end
  end
end
