Thinkspace::Html::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/html' do

      resources :contents, only: [:show, :update] do
        collection do
          get :select
        end
        member do
          post :view
          post :validate
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
