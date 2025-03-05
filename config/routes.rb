Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'users', to: 'users#create'
      post 'transactions/borrow', to: 'transactions#borrow_book'
      post 'transactions/return', to: 'transactions#return_book'
    end
  end
end
