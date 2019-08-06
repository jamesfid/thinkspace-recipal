import ember       from 'ember'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  get_store: -> totem_scope.get_store()

  get_current_user: -> totem_scope.get_current_user()

  load_records_into_store: (value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      records = value.records
      return resolve() if ember.isBlank(records)
      @store.pushPayload(records)
      resolve()

  find_record: (type, id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) if ember.isBlank(type) or ember.isBlank(id)
      @store.find(type, id).then (record) =>
        resolve(record)

  get_assignment: ->
    assignment = @casespace.get_current_assignment()
    totem_error.throw @, "Cannot join assignment server events.  Assignment is blank."  if ember.isBlank(assignment)
    assignment

  get_phase: ->
    phase = @casespace.get_current_phase()
    totem_error.throw @, "Cannot join phase server events.  Phase is blank."  if ember.isBlank(phase)
    phase
