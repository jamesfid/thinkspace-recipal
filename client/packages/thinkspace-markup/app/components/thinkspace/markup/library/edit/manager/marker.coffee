import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  model:      null
  is_editing: null
  tagName: ''

  model_text: ember.computed 'model', ->
    @get('model')

  actions:
    remove_tag: ->
      @sendAction('remove_tag', @get('model'))