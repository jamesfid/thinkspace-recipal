module Thinkspace; module IndentedList; module Concerns; module SerializerOptions; module Admin; module Lists

  def update(serializer_options)
    serializer_options.remove_association  :authable
    serializer_options.remove_association  :listable
    serializer_options.blank_association   :thinkspace_indented_list_responses
    serializer_options.blank_association   :thinkspace_indented_list_expert_responses
    serializer_options.include_ability(
        scope:   :root,
        update:  serializer_options.authable_ability[:update],
      )
  end

  def set_expert_response(serializer_options); end

end; end; end; end; end; end
