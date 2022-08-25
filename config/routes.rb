Rails.application.routes.draw do
  # root
  root 'articles#index'
  # Filter latest articles
  get 'articles/popular' => 'articles#popular'

  # Static pages
  get '/help' => 'static_pages#help'
  get '/contact' => 'static_pages#contact'
  get '/about' => 'static_pages#about'

  # Session tracking routes
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  
  # Users routes
  get 'signup'     => 'users#new'

  resources :users do
    get  '/profile'   => 'users#show_user_articles'
    get  '/favorites' => 'users#favorites'
    resources :articles, only: [:edit, :create, :destroy] do
      collection do
        delete :destroy_all
      end
    end
  end
  
  # Articles & Comments routes
  resources :articles do 
    post '/favorites' => 'users#add_favorite'
    delete  '/favorites' => 'users#remove_favorite'
    resources :comments, only: [:edit, :create, :destroy] do
      collection do
        delete :destroy_all
      end
    end
  end

  patch '/articles/:article_id/comments/:id' => 'comments#update'
  
end
