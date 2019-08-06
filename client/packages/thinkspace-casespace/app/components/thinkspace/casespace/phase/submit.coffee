import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  # ### Services
  tvo:           ember.inject.service()
  phase_manager: ember.inject.service()

  # ### Properties
  is_view_only:           ember.computed.bool  'phase_manager.is_view_only'
  is_edit:                ember.computed.bool  'tvo.status.is_edit'
  has_responses:          ember.computed.bool  'tvo.status.elements'
  valid_elements_count:   ember.computed.reads 'tvo.status.elements.count.valid'
  invalid_elements_count: ember.computed.reads 'tvo.status.elements.count.invalid'
  submit_messages_title:  ember.computed.reads 'tvo.hash.phase_submit_messages_title'
  submit_messages:        ember.computed.reads 'tvo.hash.phase_submit_messages'
  
  actions:
    submit: -> @sendAction('submit')
