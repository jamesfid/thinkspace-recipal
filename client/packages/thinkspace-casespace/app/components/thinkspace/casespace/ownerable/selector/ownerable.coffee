import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  casespace:     ember.inject.service()
  phase_manager: ember.inject.service()

  # ### Properties
  tagName: 'li'
  model:   null

  # ### Computed properties
  addon_ownerable:             ember.computed.reads 'casespace.active_addon_ownerable'
  current_user:                ember.computed.reads 'totem_scope.current_user'
  is_current_user:             ember.computed 'model', 'current_user', -> @get('model') == @get('current_user')
  is_selected_addon_ownerable: ember.computed 'addon_ownerable', -> @get('model') == @get('addon_ownerable')

  # ### Events
  click: -> @send 'select'

  actions:
    select: -> @sendAction 'select', @get 'model'