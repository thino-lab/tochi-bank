# リクエスト単位の一時属性
class Current < ActiveSupport::CurrentAttributes
  attribute :profile

  def company = profile&.company
end
