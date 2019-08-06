module Thinkspace
  module ObservationList
    module Api
      class ObservationNotesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!

        def create
          @observation_note.value = params_root[:value]
          controller_save_record(@observation_note)
        end

        def update
          @observation_note.value = params_root[:value]
          controller_save_record(@observation_note)
        end

        def destroy
          controller_destroy_record(@observation_note)
        end

      end
    end
  end
end
