class CustomerPolicy < ApplicationPolicy
  # 土地を紹介する（紹介の作成）
  def propose? = update?
end
