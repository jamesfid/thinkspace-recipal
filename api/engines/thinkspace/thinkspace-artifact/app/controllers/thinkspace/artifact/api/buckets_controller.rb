module Thinkspace
  module Artifact
    module Api
      class BucketsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! read: [:view]
        totem_action_serializer_options

        def show
          controller_render(@bucket)
        end

        def view
          controller_render_view(@bucket)
        end

      end
    end
  end
end