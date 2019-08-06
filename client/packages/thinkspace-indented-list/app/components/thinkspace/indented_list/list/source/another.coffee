import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['indented-list_new-other-container']

  get_container:        -> @$()
  get_item_values:      -> @get('item_values')
  get_response_manager: -> @get('response_manager')

  willInsertElement: -> @get_response_manager().register_source_container @, @get_container(), callback: 'set_new_item_values'

  set_new_item_values: ($el, new_item) ->
    rm          = @get_response_manager()
    item_values = rm.get_source_element_html_model_attributes($el)
    new_item.description = item_values.itemable_type
    new_item.icon        = 'lab'
    null

  get_item: (n) ->
    item =
      drag_text:   "--> other item #{n}"
      description: "*** other item #{n} list text ***"

  other_list_items: ember.computed ->
    items = []
    items.push @get_item(1)
    items.push @get_item(2)
    items.push @get_item(3)
    items.push @get_item(4)
    items.push @get_item(5)
    items
