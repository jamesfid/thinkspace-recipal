import ember      from 'ember'
import ns         from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  tagName:           ''
  model:             null
  selected:          null

  is_selected: ember.computed 'model', 'selected', -> ember.isEqual(@get('model'), @get('selected'))

  # Upstream actions
  set_team_set: 'set_team_set'

  actions:
    set_team_set: -> @sendAction 'set_team_set', @get('model')