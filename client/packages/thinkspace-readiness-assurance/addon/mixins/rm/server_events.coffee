import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  # Currently only server-events for assignment/current_user are used.
  join_server_event_received_event: ->
    @ra.join_with_current_user() unless @is_admin
