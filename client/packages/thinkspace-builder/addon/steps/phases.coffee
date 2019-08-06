import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import step  from 'thinkspace-builder/step'

export default step.extend
  # ### Properties
  title:          'Phases'
  id:             'phases'
  component_path: ns.to_p 'builder', 'steps', 'phases'
  route_path:     ns.to_r 'builder', 'cases', 'phases'

  # ### State checkers
  is_completed: ember.computed 'builder.step', 'builder.model', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('builder').get_assignment().then (assignment) =>
        assignment.totem_data.metadata.refresh().then =>
          resolve assignment.get('metadata.count') > 0
    ta.PromiseObject.create promise: promise