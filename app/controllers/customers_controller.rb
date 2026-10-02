class CustomersController < ApplicationController
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    authorize Customer
    @customers = policy_scope(Customer).includes(:in_charge_user).order(created_at: :desc).page(params[:page])
  end

  def show
    @proposals = @customer.land_proposals.active.includes(:land).order(created_at: :desc)
    proposed_ids = @proposals.map(&:land_id)
    @candidate_lands = policy_scope(Land).proposable.where.not(id: proposed_ids).order(created_at: :desc).limit(50)
  end

  def new
    @customer = authorize current_company.customers.new(in_charge_user: current_profile)
  end

  def create
    @customer = authorize current_company.customers.new(customer_params)
    if @customer.save
      redirect_to @customer, notice: "顧客を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "顧客を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.soft_delete!
    redirect_to customers_path, notice: "顧客を削除しました"
  end

  private

  def set_customer
    @customer = authorize policy_scope(Customer).find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :name, :name_kana, :email, :tel, :budget_max_man_yen, :desired_land_area_tsubo, :desired_area, :in_charge_user_id
    )
  end
end
