Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:show, :create] do
        member do
          get 'reports'
        end
      end
      resources :books, only: [] do
        member do
          get 'income'
        end
      end
      post 'transactions/borrow', to: 'transactions#borrow_book'
      post 'transactions/return', to: 'transactions#return_book'
    end
  end
end
