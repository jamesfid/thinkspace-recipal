import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  is_editing_note: false

  c_observation_note_edit: ns.to_p 'observation_note', 'edit'

  totem_data_config: ability: {model: 'observation'}
  can_update:        ember.computed.and 'not_viewonly', 'can.update'

  edit_on:  -> @set 'is_editing_note', true
  edit_off: -> @set 'is_editing_note', false
  
  actions:
    edit: ->
      @edit_on()
      @sendAction 'edit'
    update: ->
      @edit_off()
      @sendAction 'update', @get('model')
    destroy: ->
      @edit_off()
      @sendAction 'remove', @get('model')
    cancel: ->
      @edit_off()
      @sendAction 'cancel', @get('model')
