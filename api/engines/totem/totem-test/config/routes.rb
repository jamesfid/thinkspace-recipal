Totem::Test::Engine.routes.draw do
  namespace :api do

    scope path: '/totem/test/' do

      resources :errors, only: [] do
        collection do
          get :access_denied
          get :not_found
          get :server
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end

end
