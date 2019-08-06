Thinkspace::Lab::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/lab' do

      scope module: :admin do
        resources :charts, only: [] do
          get  :load, on: :member
          post :category_positions, on: :member
        end
        resources :categories, only: [:create, :update, :destroy] do
          post :result_positions, on: :member
        end
        resources :results, only: [:create, :update, :destroy] do
        end
      end

      resources :charts, only: [:show] do
        collection do
          get :select
        end
        member do
          post :view
        end
      end

      resources :observations, only: [:create, :update]

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
