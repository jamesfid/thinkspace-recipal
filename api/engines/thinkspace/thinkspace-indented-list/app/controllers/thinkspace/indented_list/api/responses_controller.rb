module Thinkspace
  module IndentedList
    module Api
      class ResponsesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def create
          # authorized response items itemables?
          validate_and_set_response_data
          controller_save_record(@response)
        end

        def show
          controller_render(@response)
        end

        def update
          # access_denied "Save error test."
          # sleep(5) # test ember response save queue
          validate_and_set_response_data
          access_denied "Could not save indented list response.  Validation errors: #{@response.errors.messages}."  unless @response.save
          controller_render_no_content
        end

        private

        def validate_and_set_response_data
          list  = @response.thinkspace_indented_list_list
          access_denied "Response id #{@response.id} list is blank."  if list.blank?
          access_denied "Cannot save a response on an expert list [id #{list.id}]."  if list.expert?
          value = params_root[:value]
          access_denied "Response value is not a hash."  unless value.is_a?(Hash)
          access_denied "Response value does not contain an 'items' key."  unless value.has_key?(:items)
          @response.user_id = current_user.id
          @response.value   = value
        end

        def access_denied(message)
          raise_access_denied_exception(message, action_name.to_sym, @response)
        end

      end
    end
  end
end
