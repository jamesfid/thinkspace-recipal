Thinkspace::ObservationList::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/observation_list' do

      scope module: :admin do
        resources :lists, only: [:update] do
          member do
            get :groups
            get :assignable_groups
            put :assign_group
            put :unassign_group
          end
        end

        resources :groups, only: [:create, :update]
      end

      resources :lists, only: [:show] do
        collection do
          get :select
        end
        member do
          post :view
          put  :observation_order
        end
      end

      resources :observations,      only: [:create, :update, :destroy]
      resources :observation_notes, only: [:create, :update, :destroy]

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
