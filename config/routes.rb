Omnom::Engine.routes.draw do
  root :to => 'feeds#index'
  
  resources :feeds, only: [:index, :show]
  
  put '/posts/update_all' => 'posts#update_all', as: 'update_all_posts'
end
