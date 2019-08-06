module Thinkspace
  module Lab
    module Api
      class ObservationsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        # totem_action_serializer_options

        def create
          save_observation
        end

        def update
          save_observation
        end

        private

        def params_observation_value_hash; params_root[:value] || Hash.new; end

        def save_observation
          serializer_options.remove_association :ownerable
          serializer_options.except_attributes(:archive)  unless totem_action_authorize.can_update_record_authable?
          if @observation.is_updateable?
            @observation.set_key_values(params_observation_value_hash)
            @observation.increment_attempts
            controller_save_record(@observation)
          else
            totem_action_authorize.access_denied "Observation cannot be updated in state #{@observation.state.inspect}."
          end
        end

      end
    end
  end
end
