import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  message_present: ember.computed.bool  'totem_messages.message_present'
  messages:        ember.computed.reads 'totem_messages.message_queue'
  is_debug:        ember.computed.bool  'totem_messages.debug_on'

  c_message: ns.to_p 'dock', 'messages', 'message'

  actions:
    toggle_addon_visible: ->
      @send 'clear_all' if @get('is_addon_visible')
      @toggleProperty('is_addon_visible')
      return

    clear_all: ->
      @totem_messages.clear_all()