Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  devise_scope :user do
    get "/users/sign_up",  :to => "home#index"
  end
  devise_for :users

  root to: "home#index"

  resources :members
  resources :blogs
  resources :board_members
  resources :announcements, only: :index
  resources :events, only: :index

  get '/strategic_plan', to: 'strategic_plans#show', as: 'strategic_plan'
  get '/Strategic_Plan', to: 'strategic_plans#show'
  resources :strategic_plans, only: [:edit, :update]

  # Routes used by member registration pages
  get 'registration', to: "registration#index", as: "registration"
  get 'registration/success', to: 'registration#success', as: 'success'
  get '/discounted_membership', to: "registration#discounted_membership", as: 'discounted_membership'
  get 'discounted_membership/about', to: "registration#about_discounted_membership", as: 'about_discounted_membership'
  get 'member_search', to: "member_search#index", as: "member_search"
  get "member_search/results", to: "member_search#show", as: "member_search_results"
  mount Members::API => '/api/members'

  # Admin routes
  get "/admin/menu", to: "admin#index", as: "admin"
  put "admin/update_settings", to: "admin#update_settings", as: 'update_settings'

  # Webhook to accept transaction updates from PayPal
  post '/payment_webhook', to: 'webhooks#create', as: 'payment_webhook'

  namespace :v1 do
    resources :events, only: [:index]
  end

end
