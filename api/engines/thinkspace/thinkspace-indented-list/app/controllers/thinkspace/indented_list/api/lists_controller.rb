module Thinkspace
  module IndentedList
    module Api
      class ListsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@list)
        end

        def view
          sub_action = serializer_options.sub_action
          case sub_action
          when :expert
            access_denied "List sub action #{sub_action} is not for an expert list."  unless @list.expert?
            controller_render_view(@list)
          when :user
            access_denied "List sub action #{sub_action} is not for an expert list."  unless @list.expert?
            controller_render_json(get_view_user_response_json)
          else
            controller_render_view(@list)
          end
        end

        private

        def get_view_user_response_json
          type_to_class = Hash.new
          itemables     = Hash.new
          ownerable     = serializer_options.params_ownerable
          list_id       = @list.expert_list_list_id
          access_denied "Expert list id is blank."  if list_id.blank?
          list = controller_model_class.find_by(id: list_id)
          access_denied "Expert list [id: #{list_id}] not found."  if list.blank?
          response       = list.thinkspace_indented_list_responses.find_by(ownerable: ownerable)
          (response.present? && response.value.present?) ? value = response.value.deep_symbolize_keys : value = Hash.new
          items          = value[:items] || Array.new
          response_items = Array.new
          items.each do |item|
            next if item.blank?
            type = item[:itemable_type]
            id   = item[:itemable_id]
            path = item[:itemable_value_path]
            case
            when type.blank? && id.blank?
              response_items.push(item.dup)
            when type.present? && id.present?
              klass    = (type_to_class[type] ||= get_type_class(type))
              itemable = klass.find_by(id: id, ownerable: ownerable)
              access_denied "Response item not found #{item.inspect}."  if itemable.blank?
              new_item               = item.symbolize_keys.except(:itemable_type, :itemable_id, :itemable_value_path)
              new_item[:description] = get_itemable_description(itemable, path)
              response_items.push(new_item)
            else
              access_denied "Response item must have both type and id or neither #{item.inspect}."
            end
          end
          response_items
        end

        def get_type_class(type)
          class_name = type.classify
          klass      = class_name.safe_constantize
          access_denied "Class name #{class_name.inspect} cannot be constantized."  if klass.blank?
          klass
        end

        def get_itemable_description(itemable, path)
          path = 'value' if path.blank?
          itemable.attributes.dig *path.split('.')
        end

        def access_denied(message, user_message='')
          action = (self.action_name || '').to_sym
          raise_access_denied_exception(message, action, @list,  user_message: user_message)
        end

      end
    end
  end
end
