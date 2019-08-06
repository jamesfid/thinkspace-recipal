import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['indented-list_new-mechanism-container']

  get_container:        -> @$()
  get_item_values:      -> @get('item_values')
  get_response_manager: -> @get('response_manager')

  willInsertElement: -> @get_response_manager().register_source_container @, @get_container(), item_values: @get_item_values()

  item_values:
    description: 'New Mechanism'
    class_names: 'mechanism'
    icon:        'mechanism'
