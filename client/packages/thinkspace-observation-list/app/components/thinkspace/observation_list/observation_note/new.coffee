import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  note_content: null

  actions:
    done:   -> @sendAction 'done', @get('note_content')
    cancel: -> @sendAction 'cancel'

  didInsertElement: -> @$('textarea').focus()
