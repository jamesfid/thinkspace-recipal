import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  input_value: null

  justification_disabled: ember.computed.or 'qm.readonly', 'qm.justification_disabled'

  actions:
    save: ->
      return if @get('justification_disabled')
      @sendAction 'save', @get('input_value')
      @set 'show_save', false

  focusOut: -> @send 'save'
