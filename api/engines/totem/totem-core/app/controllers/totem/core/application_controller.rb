module Totem
  module Core

    class ApplicationController < ActionController::Base
      protect_from_forgery

      def serve_index_from_redis
        redis = Redis.new(url: Rails.application.secrets.redis_url)
        # Redis keys are stored in the format of 'cnc:VERSION'.
        # => 'cnc:current' returns the VERSION to request cnc:VERSION which houses the HTML.
        version = params[:version]
        if version.present?
          index = redis.get("#{version}")
        else
          # returns as `cnc:ah93923` in ember-deploy
          version = redis.get("client:current") 
          # needs to get off of just the revision
          index   = redis.get("#{version}")
        end
        redis.disconnect!
        render text: index
      end

      private

      def serializer_options
        @serializer_options ||= new_serializer_options
      end

      def reset_serializer_options
        @serializer_options = new_serializer_options
      end

      def new_serializer_options
        defaults = ::Totem::Settings.authorization.current_serializer_defaults(self) || {}
        # Pass in the controller and the defaults to serializer options class.
        ::Totem::Settings.class.totem.serializer_options.new(self, defaults)
      end
      
    end

  end
end
