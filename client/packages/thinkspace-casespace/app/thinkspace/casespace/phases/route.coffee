import ember from 'ember'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  model: (params) ->
    @store.find(@ns.to_p('assignment'), params.assignment_id).then (assignment) =>
      @totem_messages.api_success source: @, model: assignment
    , (error) =>
      @totem_messages.api_failure error, source: @, model: @ns.to_p('assignment')

  afterModel: ->
    @totem_messages.show_loading_outlet(message: 'Loading...')
    new ember.RSVP.Promise (resolve, reject) =>
      ember.run.later @, (=> resolve()), 50