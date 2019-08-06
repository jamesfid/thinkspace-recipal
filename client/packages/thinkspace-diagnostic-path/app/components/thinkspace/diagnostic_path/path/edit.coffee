import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  didInsertElement: ->
    $input = @$('input')
    $input.focus()

  focusOut: -> @sendAction 'save'
