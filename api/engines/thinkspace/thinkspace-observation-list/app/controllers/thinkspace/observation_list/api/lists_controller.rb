module Thinkspace
  module ObservationList
    module Api
      class ListsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          # Typically would just do 'controller_render(@list)', but ember-data will ignore the 'first'
          # record in a plural-key array if a singular-key record exists (and then send a 'select' id request
          # for the first array record -- assuming it is referenced by the other records).
          # Since lists have an association to other lists, both the singular-key and plural-key are in the json.
          # e.g. thinkspace/observation_list/list and thinkspace/observation_list/lists
          # To work around this, deleting the singular-key record and adding it as the 'first' record in the pluray-key array
          # as ember-data will use this record as the response to store.find(id) (e.g. show) and side-load the other records.
          # Caution: If first record is not the id of the show request, ember-data will assume this is the show response record
          #          and it will become the 'content' of the ember show controller.
          # Note: The 'plural_root: false' is not needed unless the default serializer options are changed to true (e.g. future proof it).
          hash = controller_as_json(@list, plural_root: false)
          hash[controller_plural_path].delete_if {|l| l[:id] == @list.id}  # removing exising @list in hash since putting as first element below
          hash[controller_plural_path].unshift hash.delete(controller_singular_path)
          controller_render_json(hash)
        end

        def select
          controller_render(@lists)
        end

        def view
          # controller_render_view(@list)
          lists = @list.thinkspace_observation_list_lists
          controller_render_view(lists)
        end

        def observation_order
          update_observation_positions
          controller_render_no_content
        end

        private

        def update_observation_positions
          ownerable = serializer_options.params_ownerable
          return if ownerable.blank?
          changes = params[:order]
          return if changes.blank?
          access_denied "Observation position changes must an array."  unless changes.is_a?(Array)
          changes.each {|c| access_denied "Observation position changes must be an array of hashes #{c.inspect}."  unless c.is_a?(Hash)}
          changes.each {|c| access_denied "Observation position changes must have an id #{c.inspect}."  if c[:id].blank?}
          list_ids        = @list.thinkspace_observation_list_lists.pluck(:id)
          ids             = changes.map {|c| c[:id]}
          change_list_ids = observation_class.where(ownerable: ownerable, id: ids).pluck(:list_id)
          access_denied "Observation list mismatch for ownerable."  unless (change_list_ids - list_ids).blank?
          changes.each do |hash|
            id  = hash[:id]
            pos = hash[:position]
            access_denied "Observation position change id is blank #{hash.inspect}."  if id.blank?
            access_denied "Observation position position is blank #{hash.inspect}."   if pos.blank?
            access_denied "Observation position position is invalid #{hash.inspect}." unless pos.to_s.match(/^\d+$/)
            observation = observation_class.find_by(id: id, list_id: list_ids, ownerable: ownerable)
            access_denied "Observation with [id: #{id}] and ownerable [id: #{ownerable.id}] not found." if observation.blank?
            observation.update_columns(position: pos)
          end
        end

        def observation_class; Thinkspace::ObservationList::Observation; end

        def access_denied(message, user_message='')
          action = (self.action_name || '').to_sym
          raise_access_denied_exception(message, action, @list,  user_message: user_message)
        end

      end
    end
  end
end
