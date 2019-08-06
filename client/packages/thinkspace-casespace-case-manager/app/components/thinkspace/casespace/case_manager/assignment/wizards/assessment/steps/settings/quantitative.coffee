import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'

export default base.extend val_mixin,
  # Properties
  type:              null
  methodology:       null
  methodology_types: null
  options:           null
  is_categories:     ember.computed.equal 'type', 'categories'
  is_balance:        ember.computed.equal 'type', 'balance'
  is_free:           ember.computed.equal 'type', 'free'

  # Components
  c_categories: ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'quantitative', 'categories'
  c_balance:    ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'quantitative', 'balance'
  c_free:       ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'quantitative', 'free'
  c_assessment_type: ember.computed 'type', -> @get "c_#{@get('type')}"

  # Upstream actions
  set_type:                       'set_type'
  set_points_per_member:          'set_points_per_member'
  set_points_max:                 'set_points_max'
  set_points_min:                 'set_points_min'
  set_points_different:           'set_points_different'
  set_points_descriptive_enabled: 'set_points_descriptive_enabled'
  set_points_descriptive_values:  'set_points_descriptive_values'
  add_quantitative_item:          'add_quantitative_item'

  actions:
    set_points_per_member:          (value) ->  @sendAction 'set_points_per_member', value 
    set_points_max:                 (value) ->  @sendAction 'set_points_max', value
    set_points_min:                 (value) ->  @sendAction 'set_points_min', value
    set_points_different:           (value) ->  @sendAction 'set_points_different', value
    set_points_descriptive_enabled: (value) ->  @sendAction 'set_points_descriptive_enabled', value
    set_points_descriptive_values:  (values) -> @sendAction 'set_points_descriptive_values', values
    set_type:                       (type) ->   @sendAction 'set_type', type
    add_quantitative_item:          -> @sendAction 'add_quantitative_item'
    