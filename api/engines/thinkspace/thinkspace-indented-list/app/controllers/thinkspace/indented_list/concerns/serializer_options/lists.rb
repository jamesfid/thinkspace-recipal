module Thinkspace; module IndentedList; module Concerns; module SerializerOptions; module Lists

  def show(serializer_options)
    serializer_options.remove_association  :authable
    serializer_options.remove_association  :listable
    serializer_options.blank_association   :thinkspace_indented_list_responses
    serializer_options.blank_association   :thinkspace_indented_list_expert_responses
    serializer_options.include_ability(
        scope:   :root,
        update:  serializer_options.authable_ability[:update],
      )
  end

  def view(serializer_options)
    serializer_options.remove_association  :ownerable
    serializer_options.remove_association  :thinkspace_common_user
    serializer_options.include_association :thinkspace_indented_list_responses, scope_association: :params_ownerable
    case serializer_options.sub_action
    when :expert
      serializer_options.remove_association  :thinkspace_indented_list_responses
      serializer_options.include_association :thinkspace_indented_list_expert_responses, scope_association: {scope_active: nil}
    when :user
      serializer_options.remove_association  :thinkspace_indented_list_expert_responses
      serializer_options.remove_association  :thinkspace_indented_list_responses
    else
      add_response_view_abilities(serializer_options)
    end
  end

  def add_response_view_abilities(serializer_options)
    serializer_options.include_ability(
      scope:  :thinkspace_indented_list_responses,
      update: serializer_options.ownerable_ability[:update],
    )
  end

end; end; end; end; end
