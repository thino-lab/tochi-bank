# 認可の基底クラス（Pundit）。
# user は Profile（ログイン中のスタッフ）。レコードは必ず同じ企業のものだけ操作できる。
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?   = signed_in?
  def show?    = same_company?
  def create?  = signed_in?
  def new?     = create?
  def update?  = same_company?
  def edit?    = update?
  def destroy? = same_company?

  private

  def signed_in? = user.present?

  def same_company?
    signed_in? && record.respond_to?(:company_id) && record.company_id == user.company_id
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # 自社 × 論理削除されていないレコードだけを返す
    def resolve
      return scope.none if user.nil? || user.company_id.blank?
      scope.active.where(company_id: user.company_id)
    end

    private

    attr_reader :user, :scope
  end
end
