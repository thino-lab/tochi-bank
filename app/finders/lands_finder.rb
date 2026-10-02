# 土地一覧の検索条件を組み立てるクエリオブジェクト。
# Controller は params を渡すだけにし、絞り込みロジックはここに集約する（SUGOSEKI の finders と同じ役割）。
class LandsFinder
  SORTS = {
    "new"        => { created_at: :desc },
    "price_asc"  => { price: :asc },
    "price_desc" => { price: :desc },
    "area_desc"  => { land_area_tsubo: :desc }
  }.freeze

  def initialize(scope, params = {})
    @scope = scope
    @params = params.to_h.symbolize_keys
  end

  def call
    rel = @scope
    rel = rel.where(status: @params[:status]) if Land.statuses.key?(@params[:status].to_s)
    rel = rel.where(zoning: @params[:zoning]) if Land.zonings.key?(@params[:zoning].to_s)
    rel = rel.where("price >= ?", man_yen(:price_min)) if @params[:price_min].present?
    rel = rel.where("price <= ?", man_yen(:price_max)) if @params[:price_max].present?
    rel = rel.where("land_area_tsubo >= ?", @params[:tsubo_min].to_f) if @params[:tsubo_min].present?
    rel = rel.where("land_area_tsubo <= ?", @params[:tsubo_max].to_f) if @params[:tsubo_max].present?
    rel = keyword(rel) if @params[:q].present?
    rel.order(SORTS.fetch(@params[:sort].to_s, SORTS["new"]))
  end

  private

  # 画面の価格入力は「万円」
  def man_yen(key) = (@params[key].to_f * 10_000).to_i

  def keyword(rel)
    like = "%#{ActiveRecord::Base.sanitize_sql_like(@params[:q].to_s.strip)}%"
    rel.where("name LIKE :q OR prefecture LIKE :q OR city LIKE :q OR address_detail LIKE :q", q: like)
  end
end
