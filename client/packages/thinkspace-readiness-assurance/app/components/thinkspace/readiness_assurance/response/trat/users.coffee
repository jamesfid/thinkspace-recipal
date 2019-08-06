import ember from 'ember'
import ns    from 'totem/ns'
import user_list_mixin from 'thinkspace-readiness-assurance/mixins/user_list'

export default ember.Component.extend user_list_mixin,

  header: ember.computed.reads 'rm.room_users_header'
  room:   ember.computed.reads 'rm.room'
  users:  ember.computed.reads 'rm.room_users'

  willInsertElement: -> @setup()
  willDestroy:       -> @rm.leave_room @get_room_type()

  setup: ->
    @rm.join_room
      source:                   @
      room_type:                @get_room_type()
      callback:                 'handle_room_users'
      after_authorize_callback: 'refresh_users'
    @set_all_sorted_users()
