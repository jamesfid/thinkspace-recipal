Thinkspace::DiagnosticPathViewer::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/diagnostic_path_viewer' do
      resources :viewers, only: [:show] do
        post :view, on: :member
      end
      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
