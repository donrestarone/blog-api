Rails.application.routes.draw do


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  # api
  namespace :api do
  	namespace :v1 do
  		resources :posts, only: [:index, :show, :create, :destroy, :update]
  	end
  end
end
