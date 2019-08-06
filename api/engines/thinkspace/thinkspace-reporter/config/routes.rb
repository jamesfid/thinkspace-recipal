Thinkspace::Reporter::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/reporter' do
      
    	resources :reports, only: [:index, :destroy] do
        collection do
          post :generate
        end

        member do
          get :access
        end
      end

    end
  end
end
