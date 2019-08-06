import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  model:             null
  selected_template: null
  tagName:           ''

  # ### Computed properties
  is_selected: ember.computed 'model', 'selected_template', -> ember.isEqual(@get('model'), @get('selected_template'))

  actions:
    select: ->
      @sendAction 'select', @get 'model'