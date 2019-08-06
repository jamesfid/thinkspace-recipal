module Thinkspace
  module InputElement
    module Api
      class ResponsesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! read: [:carry_forward]
        totem_action_serializer_options

        def create
          @response.user_id    = current_user.id
          @response.value      = params_root[:value]
          @response.element_id = params_association_id(:element_id)
          authorize!(:create, @response)
          controller_save_record(@response)
        end

        def update
          @response.user_id = current_user.id
          @response.value   = params_root[:value]
          controller_save_record(@response)
        end

        def carry_forward
          names                  = params[:element_names]
          element_map, responses = totem_action_authorize.get_carry_forward_element_map_and_responses(names)
          hash                   = controller_as_json(responses)
          hash[:element_map]     = element_map
          controller_render_json(hash)
        end

      end
    end
  end
end
