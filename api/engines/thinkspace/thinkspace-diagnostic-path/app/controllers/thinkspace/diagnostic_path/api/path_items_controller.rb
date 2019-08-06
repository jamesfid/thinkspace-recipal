module Thinkspace
  module DiagnosticPath
    module Api
      class PathItemsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        before_filter :set_path_and_parent_in_params, only: :create
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! allow_blank_associations: {create: [:path_itemable, :parent_id]}
        totem_action_serializer_options

        def create
          authorized_path_item_ownerables
          @path_item.position    = params_root[:position]
          @path_item.description = params_root[:description]
          controller_save_record(@path_item)
        end

        def show
          controller_render(@path_item)
        end

        def update
          if (parent_id = params_root[:parent_id]).present?
            id     = @path_item.id
            parent = controller_model_class.find_by(id: parent_id)
            access_denied "Attempting to change the parent id of path item [id: #{id}] to #{parent_id} but the parent is not found."  if parent.blank?
            access_denied "Attempting to change the parent id of path item [id: #{id}] to #{parent_id} but the parent is not the same path."  unless @path_item.path_id == parent.path_id
            @path_item.parent_id = parent_id
          else
            @path_item.parent_id = nil
          end
          @path_item.position    = params_root[:position]
          @path_item.description = params_root[:description]
          controller_save_record(@path_item)
        end

        private

        # For a create, the 'path_id' and 'parent_id' are sent in the params rather than in their full path.
        # This sets the full path value so totem_action_authorize! can set the association records.
        def set_path_and_parent_in_params
          params_root[controller_association_params_key + '/path_id']   = params_root[:path_id]
          params_root[controller_association_params_key + '/parent_id'] = params_root[:parent_id]
        end

        def authorized_path_item_ownerables
          ownerable        = @path_item.ownerable
          params_ownerable = totem_action_authorize.params_ownerable
          access_denied "Path item ownerable is not the params ownerable."  unless ownerable == params_ownerable
          if (path_itemable = @path_item.path_itemable).present?
            path_itemable_ownerable = path_itemable.ownerable
            access_denied "Invalid path_itemable ownerable for path_item." unless ownerable == path_itemable_ownerable
          end
        end

        def access_denied(message)
          raise_access_denied_exception(message, totem_action_authorize.action, @path_item)
        end

      end
    end
  end
end
