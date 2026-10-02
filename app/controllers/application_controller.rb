# スタッフ向け画面の基底コントローラ。
# ・ログイン必須（require_login）
# ・データ取得は必ず policy_scope（自社 × 未削除）経由、操作前は authorize
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :require_login
  helper_method :current_profile, :current_company, :logged_in?

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def current_profile
    Current.profile ||= Profile.active.find_by(id: session[:profile_id]) if session[:profile_id]
  end
  alias_method :pundit_user, :current_profile

  def current_company = current_profile&.company
  def logged_in? = current_profile.present?

  def require_login
    redirect_to login_path, alert: "ログインしてください" unless logged_in?
  end

  def forbidden
    redirect_back fallback_location: root_path, alert: "この操作を行う権限がありません"
  end

  def not_found
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end
end
