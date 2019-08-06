Thinkspace::InputElement::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/input_element' do

      resources :responses, only: [:create, :update] do
        collection do
          post :carry_forward
        end
      end
      
      resources :elements, only: [:show]
      
      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
