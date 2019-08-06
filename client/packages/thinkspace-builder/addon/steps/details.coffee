import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import step  from 'thinkspace-builder/step'

export default step.extend
  # ### Properties
  title:          'Details'
  id:             'details'
  component_path: ns.to_p 'builder', 'steps', 'details'
  route_path:     ns.to_r 'builder', 'cases', 'details'

  is_completed: ember.computed 'builder.model', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      builder = @get 'builder'
      model   = builder.get 'model'
      return false unless ember.isPresent(model)
      builder.get_assignment().then (assignment) =>
        resolve ember.isPresent assignment.get('title')
    ta.PromiseObject.create promise: promise