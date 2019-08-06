import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  model:      null
  tagName: ''

  model_text: ember.computed 'model', ->
    if ember.isPresent(@get('model'))
      @get('model')