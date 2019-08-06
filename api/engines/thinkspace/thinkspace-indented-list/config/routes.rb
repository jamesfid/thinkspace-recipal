Thinkspace::IndentedList::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/indented_list' do

      scope module: :admin do
        resources :lists, only: [:update] do
          member do
            put :set_expert_response
          end
        end
      end

      resources :lists, only: [:show] do
        member do
          post :view
        end
      end

      resources :responses, only: [:create, :show, :update]

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end