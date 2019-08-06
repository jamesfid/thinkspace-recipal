import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  actions:
    done:   -> @sendAction 'done', @get('model')
    cancel: -> @sendAction 'cancel'

  didInsertElement: ->
    $textarea = @$('textarea')
    $textarea.focus()
    $textarea.val(@get('model.value')).trigger('autosize.resize')
