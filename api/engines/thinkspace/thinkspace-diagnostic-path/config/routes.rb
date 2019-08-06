Thinkspace::DiagnosticPath::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/diagnostic_path' do

      resources :paths, only: [:show, :update] do
        member do
          put    :bulk
          delete :bulk_destroy
          post   :view
        end
      end

      resources :path_items, only: [:create, :show, :update]

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
