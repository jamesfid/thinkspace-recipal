Thinkspace::Artifact::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/artifact' do

      scope module: :admin do
        resources :buckets, only: [:update]
      end

      resources :buckets, only: [:show] do
        post :view, on: :member
      end

      resources :files, only: [:create, :show, :destroy] do
        get  :select, on: :collection
        get  :image_url, on: :member
        post :carry_forward_image_url, on: :collection
        post :carry_forward_expert_image_url, on: :collection
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
