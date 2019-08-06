import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import step  from 'thinkspace-builder/step'

export default step.extend
  # ### Properties
  title:          'Templates'
  id:             'templates'
  component_path: ns.to_p 'builder', 'steps', 'templates'
  route_path:     ns.to_r 'builder', 'cases', 'templates'

  # ### State checkers
  is_completed: ember.computed 'builder.step', 'builder.model', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('builder').get_assignment().then (assignment) =>
        assignment.totem_data.metadata.refresh().then =>
          resolve assignment.get('metadata.count') > 0
    ta.PromiseObject.create promise: promise