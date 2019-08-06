import ember          from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  all_visible: true

  actions:
    toggle_all_visible: -> @get('response_manager').set_all_items_visibility @toggleProperty('all_visible')


