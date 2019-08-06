import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import step  from 'thinkspace-builder/step'

export default step.extend
  # ### Properties
  title:          'Overview'
  id:             'overview'
  component_path: ns.to_p 'builder', 'steps', 'overview'
  route_path:     ns.to_r 'builder', 'cases', 'overview'

  # ### Computed properties
  is_completed: ember.computed 'builder.model', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      resolve(false)
    ta.PromiseObject.create promise: promise