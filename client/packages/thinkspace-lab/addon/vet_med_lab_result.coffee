import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'

export default ember.Object.extend
  # ### Properties
  lab_observations: null
  is_focused:       false

  # ### Computed properties
  is_disabled: ember.computed 'lab_observations.@each.is_disabled', ->
    correctness      = []
    lab_observations = @get_lab_observations()
    lab_observations.forEach (lo) =>
      is_disabled = lo.get 'is_disabled'
      has_correct = lo.get_correct_value()
      correctness.pushObject is_disabled if has_correct
    !correctness.contains(false)

  # ### Events
  init: ->
    @_super()
    @set 'lab_observations', []
    @get_lab().register_lab_result(@)

  # ### Helpers
  register_lab_observation: (lab_observation) -> @get_lab_observations().pushObject(lab_observation)
  get_lab_observations:     -> @get 'lab_observations'

  get_lab: -> @get 'lab'

  # ### Focus helpers
  set_focused: ->
    @get_lab().get_lab_results().forEach (lr) => lr.reset_focused()
    @set 'is_focused', true

  reset_focused: -> @set 'is_focused', false



  toString: -> 'LabResult'