# 土地バンク（スタッフ向け）。検索は LandsFinder、表示整形は LandsHelper に任せ、ここは薄く保つ。
class LandsController < ApplicationController
  before_action :set_land, only: %i[show edit update destroy]

  def index
    authorize Land
    @lands = LandsFinder.new(policy_scope(Land), search_params).call.includes(:in_charge_user).page(params[:page])
  end

  def show
    @proposals = @land.land_proposals.active.includes(:customer).order(created_at: :desc)
  end

  def new
    @land = authorize current_company.lands.new(status: :available, in_charge_user: current_profile)
  end

  def create
    @land = authorize current_company.lands.new(land_params.merge(created_by: current_profile))
    if @land.save
      redirect_to @land, notice: "土地を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @land.update(land_params)
      redirect_to @land, notice: "土地を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @land.soft_delete!
    redirect_to lands_path, notice: "土地を削除しました"
  end

  private

  def set_land
    @land = authorize policy_scope(Land).find(params[:id])
  end

  def search_params
    params.permit(:q, :status, :zoning, :price_min, :price_max, :tsubo_min, :tsubo_max, :sort)
  end

  def land_params
    params.require(:land).permit(
      :name, :status, :price_man_yen, :postal_code, :prefecture, :city, :address_detail,
      :land_area, :land_area_tsubo, :building_coverage_ratio, :floor_area_ratio,
      :zoning, :land_category, :topography, :current_status, :has_building_conditions,
      :adjacent_road, :comment, :remarks, :in_charge_user_id
    )
  end
end
