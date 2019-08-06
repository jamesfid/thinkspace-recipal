import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from './base'

export default base_component.extend

  validate_indented_list: (status) ->
    new ember.RSVP.Promise (resolve, reject) =>
      tvo      = @get('tvo')
      rm       = @get_response_manager()
      messages = []
      status.set_is_valid(true)

      section = @get_indented_list_source_section() # section-name in the template's <component ... source='section-name'/>
      return resolve() unless section               # return if no source (e.g. observation list)

      @validate_value_items_exist(status)           # must have at least one item in the indented list
      return resolve() unless status.get_is_valid()

      action = 'itemables'                                             # source section's registered action method to get the itemables
      return resolve() unless tvo.section.has_action(section, action)  # did not register an 'itemables' action

      tvo.section.call_action(section, action).then (itemables) =>
        @validate_itemables_exist(status, itemables)  # must have at least one observation
        return resolve() unless status.get_is_valid()
        first = itemables.get('firstObject')
        type  = @totem_scope.get_record_path(first)
        itemables.forEach (itemable) =>
          id   = parseInt(itemable.get 'id')
          item = rm.is_itemable_used_by_another_item(itemable_type: type, itemable_id: id)
          @add_itemable_unused_message(status, itemable, messages) if ember.isBlank(item)
        @set_status_messages(status, messages)
        resolve()
      , (error) => reject(error)
    , (error) => reject(error)

  set_status_messages: (status, messages) ->

    # ### TESTING ONLY
    # if status.get_is_valid()
    #   messages.push "<span style='color: green; font-weight: 500'>Phase would have been submitted...............(testing only)</span>".htmlSafe()
    #   status.set_is_valid(false)
    #   status.increment_invalid_count()
    # ### TESTING ONLY

    return if status.get_is_valid()
    count   = status.get_invalid_count()
    hdr_msg = "Must use ALL observations - #{count} "
    hdr_msg += if count <= 1 then 'observation was not used.' else 'observations were not used.'
    errors  = []
    errors.push "<span style='font-weight: 500'>#{hdr_msg}</span>"
    errors.push '<ol>'
    for msg in messages
      errors.push "<li>#{msg}</li>"
    errors.push '</ol>'
    status_messages = []
    status_messages.push errors.join('').htmlSafe()
    status.set_status_messages(status_messages)

  add_itemable_unused_message: (status, itemable, messages) ->
    status.increment_invalid_count()
    status.set_is_valid(false)
    messages.push itemable.get('value')

  validate_value_items_exist: (status) ->
    items = @get_response_manager_items()
    return if ember.isPresent(items)
    status.set_is_valid(false)
    status.set_status_messages ["The diagnostic path is blank."]
  
  validate_itemables_exist: (status, itemables) ->
    return if ember.isPresent(itemables)
    status.set_is_valid(false)
    status.set_status_messages ["No observations present."]
