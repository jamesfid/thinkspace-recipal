namespace :thinkspace do
  namespace :indented_list do
    namespace :expert_path do

      task :port, [] => [:environment] do |t, args|
        list_class            = ::Thinkspace::IndentedList::List
        response_class        = ::Thinkspace::IndentedList::Response
        expert_response_class = ::Thinkspace::IndentedList::ExpertResponse
        user_class            = ::Thinkspace::Common::User
        user_id               = ENV['USER_ID']
        list_id               = ENV['LIST_ID']
        expert_list_id        = ENV['EXPERT_LIST_ID']

        raise "Invalid USER_ID [#{user_id}] - cannot continue." unless user_id.present?
        raise "Invalid LIST_ID [#{list_id}] - cannot continue." unless list_id.present?
        raise "Invalid EXPERT_LIST_ID [#{expert_list_id}] - cannot continue." unless expert_list_id.present?
        user = user_class.find_by(id: user_id)
        raise "Invalid user, USER_ID [#{user_id}] is not found." unless user.present?
        list = list_class.find_by(id: list_id)
        raise "Invalid list, LIST_ID [#{list_id}] is not found." unless list.present?
        expert_list = list_class.find_by(id: expert_list_id)
        raise "Invalid list, EXPERT_LIST_ID [#{expert_list_id}] is not found." unless expert_list.present?
        raise "Expert list [#{expert_list_id}] is not an expert list." unless expert_list.expert?
        user_response = response_class.find_by(ownerable: user, list_id: list_id)
        raise "No user response found for USER_ID [#{user_id}] LIST_ID: [#{list_id}]." unless user_response.present?

        items        = user_response.value['items']
        items        = [] unless items.present?
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

        expert_response             = expert_response_class.new
        expert_response.value       = {items: expert_items}
        expert_response.user_id     = user.id
        expert_response.list_id     = expert_list.id
        expert_response.response_id = user_response.id
        expert_response.state       = 'active'
        if expert_response.save
          inactivate_old_expert_responses(expert_list, expert_response)
          puts "\n [FINISH] Expert Response of: #{expert_response.inspect} \n"
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

      def inactivate_old_expert_responses(list, response)
        expert_response_class = ::Thinkspace::IndentedList::ExpertResponse
        ids                   = list.thinkspace_indented_list_expert_responses.pluck(:id)
        ids.delete(response.id)
        ids.each do |id|
          e_response = expert_response_class.find(id)
          e_response.state = 'inactive'
          e_response.save
        end
      end

    end
  end
end