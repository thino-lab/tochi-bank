class SessionsController < ApplicationController
  skip_before_action :require_login
  layout "auth"

  def new
    redirect_to root_path if logged_in?
  end

  def create
    profile = Profile.active.find_by(email: params[:email].to_s.strip.downcase)
    if profile&.authenticate(params[:password])
      reset_session
      session[:profile_id] = profile.id
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "ログアウトしました"
  end
end
