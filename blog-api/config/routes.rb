Rails.application.routes.draw do


  # get 'blogs/index'

  # get 'blogs/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  resources :blogs, only: [:index, :show]

  # api
  namespace :api do
  	namespace :v1 do
  		resources :posts, only: [:index, :show, :create, :destroy, :update]
  	end
  end
  #api search
  get '/api/v1/posts/search', to: 'posts#search'
end
