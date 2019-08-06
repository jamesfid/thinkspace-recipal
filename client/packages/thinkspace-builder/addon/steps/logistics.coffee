import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import step  from 'thinkspace-builder/step'

export default step.extend
  # ### Properties
  title:          'Logistics'
  id:             'logistics'
  component_path: ns.to_p 'builder', 'steps', 'logistics'
  route_path:     ns.to_r 'builder', 'cases', 'logistics'

  is_completed: ember.computed 'builder.model', 'builder.step', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('builder').get_assignment().then (assignment) =>
        due_at       = assignment.get 'due_at'
        release_at   = assignment.get 'release_at'
        instructions = assignment.get 'instructions'
        resolve ember.isPresent(due_at) and ember.isPresent(release_at) and ember.isPresent(instructions)
    ta.PromiseObject.create promise: promise