import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  is_current: ember.computed 'selected_model', -> @get('model') == @get('selected_model')

  # Components
  c_radio: ns.to_p 'common', 'shared', 'radio'

  actions:
    select: -> @sendAction 'select', @get('model')

