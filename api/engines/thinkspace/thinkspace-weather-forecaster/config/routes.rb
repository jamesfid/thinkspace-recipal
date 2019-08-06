Thinkspace::WeatherForecaster::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/weather_forecaster' do

      resources :assessments, only: [:show] do
        member do
          post :view
          post :current_forecast
        end
      end

      resources :forecasts, only: [:update] do
        member do
          post :view
        end
      end

      resources :responses, only: [:create, :update]

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
