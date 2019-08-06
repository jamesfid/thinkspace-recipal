import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  actions:
    cancel: -> @sendAction 'cancel'
    ok:     -> @sendAction 'ok'