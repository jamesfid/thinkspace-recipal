module Thinkspace
  module DiagnosticPathViewer
    module Api
      class ViewersController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! record_ownerable: false

        def show
          serializer_options.remove_association  :thinkspace_common_user, :ownerable, :authable, :thinkspace_diagnostic_path_path
          controller_render(@viewer)
        end

        def view
          serializer_options.remove_association :ownerable, :authable
          serializer_options.authorize_action   :view, :thinkspace_common_user
          serializer_options.include_association(
            :thinkspace_common_user,
            :thinkspace_diagnostic_path_path,
            :thinkspace_diagnostic_path_parent,
            :thinkspace_diagnostic_path_path_items,
            :path_itemable,
            :thinkspace_observation_list_list,
            :thinkspace_observation_list_lists
          )
          sub_action = totem_action_authorize.sub_action
          case sub_action
          when :ownerable
            ownerable  = totem_action_authorize.params_ownerable
            access_denied "Params ownerable is not the current user."  unless ownerable == current_user
            serializer_options.scope_association :thinkspace_diagnostic_path_path_items, :thinkspace_observation_list_observations,
              where: {ownerable: ownerable}
          else
            serializer_options.scope_association :thinkspace_diagnostic_path_path_items, :thinkspace_observation_list_observations,
              where: {ownerable: @viewer.ownerable}
          end

          json       = controller_as_json(@viewer)
          ids        = (json['thinkspace/observation_list/observations'] || []).map { |item| item[:id] }
          key        = 'thinkspace/observation_list/observation_ids'
          lists      = json['thinkspace/observation_list/lists'] || []
          lists.each do |list|
            list[key] = list[key] & ids
          end

          controller_render_json(json)
        end

        private

        def access_denied(message)
          raise_access_denied_exception(message, totem_action_authorize.action, @assessment)
        end

      end
    end
  end
end
