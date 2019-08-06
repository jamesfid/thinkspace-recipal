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

  # Upstream actions
  set_points_max:                 'set_points_max'
  set_points_min:                 'set_points_min'

  actions:
    set_points_max:         (value) -> @sendAction 'set_points_max', value
    set_points_min:         (value) -> @sendAction 'set_points_min', value
