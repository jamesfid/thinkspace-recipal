module Thinkspace
  module InputElement
    module Api
      class ElementsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@element)
        end

      end
    end
  end
end