Rails.application.routes.draw do
  # ── スタッフ向け（ログイン必須）──
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  root "lands#index"
  resources :lands
  resources :customers do
    resources :land_proposals, only: :create
  end
  resources :land_proposals, only: :destroy

  # ── お客様専用ページ（ログイン不要・署名付きトークン）──
  scope "p/:token", module: :portal, as: :portal do
    get "/", to: "proposals#index", as: :root
    resources :proposals, only: %i[show] do
      patch :react, on: :member
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
