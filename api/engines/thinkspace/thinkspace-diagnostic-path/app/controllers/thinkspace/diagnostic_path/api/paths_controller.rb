module Thinkspace
  module DiagnosticPath
    module Api
      class PathsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@path)
        end

        def update
          @path.title = params_root[:title]
          # For an update, just save the path and don't return the updated path with path item associations
          # since the record is updated in ember-data and returning any path item associations will
          # alter the ownerable associations established in ember-data e.g. use controller_render_view.
          @path.save
          controller_render_view(@path)
        end

        def view
          controller_render_view(@path)
        end

        def bulk
          render_records   = Array.new
          path_item_params = params['path_items']
          controller_render_json({}) && return if path_item_params.blank?
          @path.transaction do
            begin
              path_item_params.each do |id, values|
                parent_id = values['parent_id']
                position  = values['position']
                path_item = get_path_item(id)
                next if not path_item
                raise BulkUnauthorized, "Params path item [id: #{id}] does not reference path [id: #{@path.id}."  unless path_item.path_id == @path.id
                if parent_id.present?
                  parent_item = get_path_item(parent_id)
                  raise BulkUnauthorized, "Params path item [id: #{id}] parent [parent_id: #{parent_id}] not found."  if parent_item.blank?
                  raise BulkUnauthorized, "Params path item [id: #{id}] parent [parent_id: #{parent_id}] does not reference path [id: #{@path.id}."  unless parent_item.path_id == @path.id
                  authorize_path_item_ownerable(parent_item)
                end
                authorize_path_item_ownerable(path_item)
                path_item.parent_id = parent_id
                path_item.position  = position
                path_item.save ? render_records.push(path_item) : (raise BulkUnauthorized, "Could not save path item [id: #{path_item.id}.")
              end
            rescue BulkUnauthorized => e
              access_denied e.message
            end
          end
          controller_render(render_records)
        end

        def bulk_destroy
          render_records   = Array.new
          path_item_params = params['path_items']
          controller_render_json({}) && return if path_item_params.blank?
          @path.transaction do
            begin
              path_item_params.each do |id|
                path_item = get_path_item(id)
                next if not path_item
                raise BulkUnauthorized, "Params path item [id: #{id}] does not reference path [id: #{@path.id}."  unless path_item.path_id == @path.id
                authorize_path_item_ownerable(path_item)
                path_item.destroy ? render_records.push(path_item) : (raise BulkUnauthorized, "Could not destroy path item [id: #{path_item.id}.")
              end
            rescue BulkUnauthorized => e
              access_denied e.message
            end
          end
          controller_render_no_content
        end

        private

        def authorize_path_item_ownerable(path_item)
          ownerable = totem_action_authorize.params_ownerable
          raise BulkUnauthorized, "Params ownerable is blank.  Cannot authorize path item [id: #{path_item.id}] ownerable."  if ownerable.blank?
          unless  ownerable.id == path_item.ownerable_id && ownerable.class.name == path_item.ownerable_type
            raise BulkUnauthorized, "Path item [id: #{path_item.id}] [type: #{path_item.ownerable_type} id: #{path_item.ownerable_id}]] is not the same ownerable [type: #{ownerable.class.name} id: #{ownerable.id}]."
          end
        end

        def get_path_item(id)
          Thinkspace::DiagnosticPath::PathItem.find_by(id: id)
        end

        def access_denied(message)
          raise_access_denied_exception(message, totem_action_authorize.action, @path)
        end

        class BulkUnauthorized < StandardError; end

      end
    end
  end
end
