Thinkspace::Markup::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/markup' do
      resources :comments, only: [:create, :update, :destroy] do
        get :fetch, on: :collection
      end

      resources :libraries, only: [:create, :update, :show] do
        get :select,             on: :collection
        put :add_tag,            on: :member
        put :remove_comment_tag, on: :member
        put :add_comment_tag,    on: :member
        get :fetch,              on: :collection
      end

      resources :library_comments, only: [:create, :update, :show, :destroy] do
        get :select, on: :collection
      end

      resources :discussions, only: [:create, :update, :destroy] do
        get :fetch, on: :collection
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
