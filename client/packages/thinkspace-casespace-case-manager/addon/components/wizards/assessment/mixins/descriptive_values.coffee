import ember from 'ember'
import ns from 'totem/ns'

export default ember.Mixin.create
  # Properties
  points_descriptive_enabled: ember.computed.reads 'points.descriptive.enabled'
  points_descriptive_values:
    not_at_all:        ['Not at all', 'Somewhat', 'Completely']
    rarely:            ['Rarely', 'Sometimes', 'Always']
    never:             ['Never', 'Sometimes', 'Always']
    strongly_disagree: ['Strongly disagree', 'Neutral', 'Strongly agree']

  is_points_descriptive_not_at_all:        false
  is_points_descriptive_rarely:            false
  is_points_descriptive_never:             false
  is_points_descriptive_strongly_disagree: false

  # Upstream actions
  set_points_descriptive_enabled: 'set_points_descriptive_enabled'
  set_points_descriptive_values:  'set_points_descriptive_values'

  # Templates
  t_points_descriptive: ns.to_t 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'quantitative', 'shared', 'points_descriptive'
    
  # Helpers
  set_points_descriptive_values_radios: (id) ->
    domain_values = @get 'points_descriptive_values'
    for key of domain_values
      @set "is_points_descriptive_#{key}", false
    property = "is_points_descriptive_#{id}"
    @set property, true

  actions:
    toggle_set_points_descriptive_enabled: -> @sendAction 'set_points_descriptive_enabled', !@get('points_descriptive_enabled')
    set_points_descriptive_values: (id) ->
      domain_values = @get 'points_descriptive_values'
      values        = domain_values[id]
      return unless ember.isPresent(values)
      @set_points_descriptive_values_radios(id)
      @sendAction 'set_points_descriptive_values', values