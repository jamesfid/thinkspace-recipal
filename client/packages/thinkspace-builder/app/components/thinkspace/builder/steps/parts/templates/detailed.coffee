import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  model:          null
  selected_phase: null

  # ### Components
  c_phase:  ns.to_p 'builder', 'steps', 'parts', 'templates', 'phase'
  c_loader: ns.to_p 'common', 'loader'

  # ### Events
  init: ->
    @_super()
    model = @get 'model'
    model.get('templateable').then (assignment) =>
      # Load the assignment to get the Phase IDs.
      @tc.query(ns.to_p('assignment'), {id: assignment.get('id'), action: 'load'}, single: true).then (assignment) =>
        phases = assignment.get(ns.to_p('phases'))
        console.error "[builder] Templateable does not have a `phases` getter." unless ember.isPresent(phases)
        phases.then (phases) =>
          phases = phases.sortBy('position')
          @set 'assignment', assignment
          @set 'phases', phases
          @set 'selected_phase', phases.get('firstObject')
          @set_all_data_loaded()


  actions:
    back: -> @sendAction 'back'
    use:  -> @sendAction 'use'

    select_phase: (phase) ->  @set 'selected_phase', phase