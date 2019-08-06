module Thinkspace; module Html; module Concerns; module SerializerOptions; module Contents

  def show(serializer_options)
    serializer_options.remove_all_except   :thinkspace_input_element_elements, scope: :root
    serializer_options.include_association :thinkspace_input_element_elements
    serializer_options.blank_association   :thinkspace_input_element_responses
    include_ability(serializer_options)
  end

  def select(serializer_options); show(serializer_options); end

  def view(serializer_options)
    serializer_options.remove_all_except   :thinkspace_input_element_element, scope: :thinkspace_input_element_responses
    serializer_options.include_association :thinkspace_input_element_elements
    serializer_options.include_association :thinkspace_input_element_responses, scope_association: :params_ownerable
  end

  def update(serializer_options); view(serializer_options); end

  def validate; end

  # ###
  # ### Helpers.
  # ###

  def include_ability(serializer_options)
    serializer_options.include_ability(
        update: serializer_options.totem_action_authorize.can_update_record_authable?,
        scope:  :root
      )
  end

  # ###
  # ### Class Methods.
  # ###

  # show
  def self.ability_content(controller, record, ownerable)
    hash          = Hash.new
    update        = controller.can?(:update, record.authable)
    hash[:update] = update
    hash[:create] = update
    hash
  end

end; end; end; end; end
