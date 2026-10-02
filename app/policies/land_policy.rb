class LandPolicy < ApplicationPolicy
  # 削除は管理者または担当者のみ
  def destroy? = super && (user.role_admin? || record.in_charge_user_id == user.id)
end
