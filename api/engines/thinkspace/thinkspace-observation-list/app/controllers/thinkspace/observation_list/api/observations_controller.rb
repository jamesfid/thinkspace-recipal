module Thinkspace
  module ObservationList
    module Api
      class ObservationsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def create
          @observation.value    = params_root[:value]
          @observation.position = params_root[:position]
          controller_save_record(@observation)
        end

        def update
          @observation.user_id  = current_user.id
          @observation.value    = params_root[:value]
          @observation.position = params_root[:position]
          controller_save_record(@observation)
        end

        def destroy
          controller_destroy_record(@observation)
        end

      end
    end
  end
end
