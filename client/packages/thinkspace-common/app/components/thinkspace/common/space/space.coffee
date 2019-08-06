import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  ttz: ember.inject.service()

  has_actions: ember.computed.and 'can.update', 'metadata.can_clone'

  dropdown_collection: ember.computed -> [
    {display: 'Clone Space', route: @get('r_spaces_clone'), model: @get('model')}
  ]

  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'
  r_spaces_show:           ns.to_r 'spaces', 'show'
  r_spaces_clone:          ns.to_r 'case_manager', 'spaces', 'clone'

  next_due_at:      ember.computed.reads 'metadata.next_due_at'
  next_due_at_date: ember.computed 'next_due_at',-> @get('ttz').format(@get('next_due_at'), format: 'MMM Do, YYYY h:mm a')

  totem_data_config: ability: {ajax_source: true}, metadata: {ajax_source: true}
