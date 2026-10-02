# 論理削除の共通実装。pg-core の deleted_at + scope :active を踏襲。
# 物理削除(destroy/delete)は使わず、削除は必ず deleted_at を立てる。
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active,  -> { where(deleted_at: nil) }
    scope :deleted, -> { where.not(deleted_at: nil) }
  end

  # 論理削除（削除日時を記録）
  def soft_delete!(at: Time.current)
    update!(deleted_at: at)
  end

  # 復元
  def restore!
    update!(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end
end
