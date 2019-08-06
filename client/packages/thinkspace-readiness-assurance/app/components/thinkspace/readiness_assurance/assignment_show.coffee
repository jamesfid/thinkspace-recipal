import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  willInsertElement: ->
    @totem_scope.authable(@get 'model')
    if @get('model.can.update')
      @ra.leave_all_except_admin_room()
      @ra.join_admin_room()
    else
      @ra.leave_all_except_current_user_server_event_room()
      @ra.join_with_current_user()
      @ra.load_messages()

      @ra.tracker()
