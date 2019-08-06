module Thinkspace
  module IndentedList
    class Response < ActiveRecord::Base
      totem_associations
      has_paper_trail

      def clone_as_expert_response(expert_list_id)
        items        = value['items'] || []
        expert_items = []
        items.each do |item|
          new_item = {
            category: item['category'],
            description: get_description_from_item(item),
            pos_x: item['pos_x'],
            pos_y: item['pos_y']
          }
          expert_items << new_item
        end
        expert_response             = Thinkspace::IndentedList::ExpertResponse.new
        expert_response.value       = {items: expert_items}
        expert_response.user_id     = self.user_id
        expert_response.list_id     = expert_list_id
        expert_response.response_id = self.id
        expert_response.state       = 'active'
        if expert_response.save
          expert_response.inactivate_others
          expert_response
        else
          raise "Error saving expert response: #{expert_response.errors.full_messages}"
        end
      end

      def get_description_from_item(item)
        return item['description'] if item.has_key?('description') && item['description'].present?
        type       = item['itemable_type']
        id         = item['itemable_id']
        value_path = item['itemable_value_path'] || 'value'
        return nil unless type.present? && id.present? && value_path.present?
        klass      = type.classify.safe_constantize
        return nil unless klass.present?
        record = klass.find(id)
        return nil unless record.present?
        record.send value_path
      end

    end
  end
end
