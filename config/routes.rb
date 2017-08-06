Rails.application.routes.draw do

  devise_scope :user do
    get "/users/sign_up",  :to => "home#index"
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  resources :members
  resources :blogs
  resources :events

  get 'registration', to: "registration#index", as: "registration"
  get 'member_search', to: "member_search#index", as: "member_search"
  get "member_search/results", to: "member_search#show", as: "member_search_results"
  get "/admin/menu", to: "admin#index", as: "admin"

end
