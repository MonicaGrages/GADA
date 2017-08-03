Rails.application.routes.draw do

  devise_scope :user do
    get "/users/sign_up",  :to => "home#index"
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

end
