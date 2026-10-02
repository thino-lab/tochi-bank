# お客様専用ページ（ログイン不要）の基底。
# アクセスは Customer#portal_token（署名付き）でのみ可能。スタッフ画面の認証・レイアウトとは完全に分離する。
module Portal
  class BaseController < ActionController::Base
    allow_browser versions: :modern
    layout "portal"

    before_action :set_customer
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def set_customer
      @customer = Customer.active.find_by_portal_token(params[:token])
      not_found if @customer.nil?
    end

    # お客様に見せてよい紹介だけ（取り消し済み・土地削除済み・成約/下書きは除外）
    def visible_proposals
      @customer.land_proposals.active.joins(:land).merge(Land.proposable)
    end

    def not_found
      render "portal/shared/not_found", status: :not_found
    end
  end
end
