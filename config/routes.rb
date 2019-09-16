Rails.application.routes.draw do

  devise_scope :user do
    get "/users/sign_up",  :to => "home#index"
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  resources :members
  resources :blogs
  resources :events do
    resources :checkins
    get 'member_search', to: 'events#member_search', as: 'member_search'
    get 'renew', to: 'events#renew', as: 'renew'
  end
  resources :board_members
  resources :announcements

  get 'registration', to: "registration#index", as: "registration"
  get 'registration/success', to: 'registration#success', as: 'success'
  get '/discounted_membership', to: "registration#discounted_membership", as: 'discounted_membership'
  get 'discounted_membership/about', to: "registration#about_discounted_membership", as: 'about_discounted_membership'
  get 'member_search', to: "member_search#index", as: "member_search"
  get "member_search/results", to: "member_search#show", as: "member_search_results"
  get "/admin/menu", to: "admin#index", as: "admin"
  put "admin/update_settings", to: "admin#update_settings", as: 'update_settings'
  post '/payment_webhook', to: 'webhooks#create', as: 'payment_webhook'
  get '/checkins', to: 'checkins#index', as: 'checkins'

  mount Events::API => '/api/events'
  mount Members::API => '/api/members'
end
