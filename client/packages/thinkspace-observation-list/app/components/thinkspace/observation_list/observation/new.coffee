import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  observation_content: null

  actions:
    done:   -> @sendAction 'done', @get('observation_content')
    cancel: -> @sendAction 'cancel'

  didInsertElement: -> @$('textarea').focus()
