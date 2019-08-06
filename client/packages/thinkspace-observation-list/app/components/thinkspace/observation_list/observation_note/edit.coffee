import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  note_text: null

  actions:
    update: ->
      @set 'model.value', @get('note_text')
      @sendAction 'update'

    cancel: -> @sendAction 'cancel'

  didInsertElement: ->
    @set 'note_text', @get('model.value')
    $textarea = @$('textarea')
    $textarea.focus()
