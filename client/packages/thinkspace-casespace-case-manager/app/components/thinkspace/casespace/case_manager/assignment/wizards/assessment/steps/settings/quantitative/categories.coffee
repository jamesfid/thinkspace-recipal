import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'
import descriptive_values from 'thinkspace-casespace-case-manager/components/wizards/assessment/mixins/descriptive_values'

export default base.extend val_mixin, descriptive_values,
  # Properties
  points:             ember.computed.reads 'options.points'
  points_min:         ember.computed.reads 'points.min'
  points_max:         ember.computed.reads 'points.max'

  # Components
  c_quantitative_item:  ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'quantitative', 'item'

  # Upstream actions
  add_quantitative_item:   'add_quantitative_item'
  set_points_max:          'set_points_max'
  set_points_min:          'set_points_min'
  set_descriptive_enabled: 'set_points_descriptive_enabled'

  actions:
    add:                            -> @sendAction 'add_quantitative_item'
    set_points_max:                 (value) -> @sendAction 'set_points_max', value
    set_points_min:                 (value) -> @sendAction 'set_points_min', value
    set_points_descriptive_enabled: (value) -> @sendAction 'set_points_descriptive_enabled', value