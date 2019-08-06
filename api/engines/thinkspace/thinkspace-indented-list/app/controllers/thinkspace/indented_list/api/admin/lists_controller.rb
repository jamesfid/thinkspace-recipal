module Thinkspace
  module IndentedList
    module Api
      module Admin
        class ListsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_authorize!
          totem_action_serializer_options

          def update
            @list.expert = params_root[:expert]
            controller_save_record(@list)
          end

          def set_expert_response
            user_id = params[:user_id] # What user to clone their Response from the list_id.
            list_id = params[:list_id] # What list to clone the user's data from.
            list    = Thinkspace::IndentedList::List.find_by(id: list_id)
            access_denied "Target list_id [#{list_id}] is not valid."   unless list.present?
            access_denied "Cannot update the target list [#{list_id}]." unless current_ability.can?(:update, list.authable)
            user    = Thinkspace::Common::User.find_by(id: user_id)
            access_denied "Target user_id [#{user_id} is not valid." unless user.present?
            response = Thinkspace::IndentedList::Response.find_by(ownerable: user, list_id: list_id)
            access_denied "No response found for ownerable: [#{user.id}] and list: [#{list_id}]", 'No valid data found for the given user and path.' unless response.present?
            response.clone_as_expert_response(@list.id)
            controller_render(@list)
          end

          private

          def access_denied(message, user_message='')
            action = (self.action_name || '').to_sym
            raise_access_denied_exception(message, action, @list,  user_message: user_message)
          end

        end
      end
    end
  end
end
