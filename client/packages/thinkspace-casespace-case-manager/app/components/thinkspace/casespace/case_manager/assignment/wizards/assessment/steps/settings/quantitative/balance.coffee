import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'
import descriptive_values from 'thinkspace-casespace-case-manager/components/wizards/assessment/mixins/descriptive_values'

export default base.extend val_mixin, descriptive_values,
  # Properties
  points:                     ember.computed.reads 'options.points'
  points_per_member:          ember.computed.reads 'points.per_member'
  points_min:                 ember.computed.reads 'points.min'
  points_max:                 ember.computed.reads 'points.max'
  points_different:           ember.computed.reads 'points.different'

  # Upstream actions
  set_points_per_member:          'set_points_per_member'
  set_points_max:                 'set_points_max'
  set_points_min:                 'set_points_min'
  set_points_different:           'set_points_different'
  set_points_descriptive_enabled: 'set_points_descriptive_enabled'
  set_points_descriptive_values:  'set_points_descriptive_values'
  # Observers
  points_different_observer:   ember.observer 'points_different', -> @sendAction 'set_points_different', @get('points_different')
  points_descriptive_observer: ember.observer 'points_descriptive_enabled', ->  @sendAction 'set_points_descriptive_enabled', @get('points_descriptive_enabled')

  # Since setting the .reads properties causes them to permanently diverge from the upstream property, reset them to what is passed in.
  # => This fixes the bug of swapping between two methodologies that have balance open.
  options_observer: ember.observer 'options', ->
    @set 'points',                     @get('options.points')
    @set 'points_per_member',          @get('points.per_member')
    @set 'points_min',                 @get('points.min')
    @set 'points_max' ,                @get('points.max')
    @set 'points_different',           @get('points.different')
    @set 'points_descriptive_enabled', @get('points.descriptive.enabled')
    @set 'points_descriptive_values',  @get('points.descriptive.values')

  actions:
    set_points_per_member:   (value) -> @sendAction 'set_points_per_member', value
    set_points_max:          (value) -> @sendAction 'set_points_max', value
    set_points_min:          (value) -> @sendAction 'set_points_min', value
    toggle_points_different: ->  @sendAction 'set_points_different', !@get('points_different')

  validations:
    points_per_member:
      numericality: true