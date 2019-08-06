import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  model:       null # PhaseState
  phase_score: null

  # ### Events
  init: ->
    @_super()
    model = @get 'model'
    model.get(ns.to_p('phase_score')).then (phase_score) => @set 'phase_score', phase_score
