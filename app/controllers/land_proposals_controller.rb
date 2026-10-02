# 顧客詳細から土地を紹介する／紹介を取り消す
class LandProposalsController < ApplicationController
  def create
    customer = authorize policy_scope(Customer).find(params[:customer_id]), :propose?
    lands = policy_scope(Land).proposable.where(id: Array(params[:land_ids]))
    if lands.empty?
      return redirect_to customer, alert: "紹介する土地を選択してください"
    end

    result = LandProposals::Propose.new(
      customer: customer, lands: lands, proposed_by: current_profile, message: params[:message].presence
    ).call
    notice = "#{result.created.size}件の土地を紹介しました"
    notice += "（#{result.skipped.size}件は紹介済み）" if result.skipped.any?
    redirect_to customer, notice: notice
  end

  def destroy
    proposal = authorize policy_scope(LandProposal).find(params[:id])
    proposal.soft_delete!
    redirect_to proposal.customer, notice: "紹介を取り消しました"
  end
end
