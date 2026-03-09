Rails.application.routes.draw do
  get "searches/search"
  root to: "homes#top"
  get "home/about", to: "homes#about", as: :about
  get "search", to: "searches#search"
  resources :users, only: [ :new, :create, :index, :show, :edit, :update ], path_names: { new: "sign_up" } do
    member do
      get :following
      get :followers
      get :daily_count
    end
  end

  resources :relationships, only: [ :create, :destroy ]

  resources :books, only: [ :index, :show, :create, :show, :edit, :update, :destroy ] do
    resource :favorite, only: [ :create, :destroy ]
    resources :book_comments, only: [ :create, :destroy ]

    collection do
      get :category_search
    end
  end

  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token

  resources :rooms, only: [ :create, :show ]
  resources :messages, only: [ :create ]
  resources :groups, only: [ :new, :create, :index, :show, :edit, :update ] do
    resources :group_users, only: [ :create, :destroy ]

    member do
      get  :new_mail
      post :send_mail
    end
  end
end
