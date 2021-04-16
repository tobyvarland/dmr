Rails.application.routes.draw do

  resources :reports do
    member do
      delete  :remove_upload
      post    :add_upload
    end
  end
  root  to: "reports#index"
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'users/sign_in', to: 'users/sessions#new', as: :new_user_session
    get 'users/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

end