Thinkspace::Simulation::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/simulation' do
      
      resources :simulations, only: [:index, :show]

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
