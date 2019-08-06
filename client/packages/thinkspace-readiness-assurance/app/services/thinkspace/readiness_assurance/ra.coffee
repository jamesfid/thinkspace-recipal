import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Service.extend

  csse:     ember.inject.service ns.to_p('casespace', 'server_events')
  messages: ember.inject.service ns.to_p('casespace', 'messages')

  c_messages: ns.to_p 'readiness_assurance', 'shared', 'messages', 'view'

  c_irat_assessment_show:          ns.to_p 'ra:assessment', 'irat', 'show'
  c_trat_assessment_show:          ns.to_p 'ra:assessment', 'trat', 'show'
  c_trat_overview_assessment_show: ns.to_p 'ra:assessment', 'trat_overview', 'show'

  c_irat_questions:       ns.to_p 'ra:response', 'irat', 'questions'
  c_irat_question:        ns.to_p 'ra:response', 'irat', 'question'
  c_irat_justification:   ns.to_p 'ra:response', 'irat',  'justification'

  c_trat_room_users:    ns.to_p 'ra:response', 'trat', 'users'
  c_trat_questions:     ns.to_p 'ra:response', 'trat', 'questions'
  c_trat_question:      ns.to_p 'ra:response', 'trat', 'question'
  c_trat_chats:         ns.to_p 'ra:response', 'trat', 'chats'
  c_trat_chat:          ns.to_p 'ra:response', 'trat', 'chat'
  c_trat_justification: ns.to_p 'ra:response', 'trat',  'justification'

  c_shared_radio_buttons:      ns.to_p 'readiness_assurance', 'shared', 'radio', 'buttons'
  c_shared_radio_button:       ns.to_p 'readiness_assurance', 'shared', 'radio', 'button'
  c_shared_radio_ifat_buttons: ns.to_p 'readiness_assurance', 'shared', 'radio', 'ifat_buttons'
  c_shared_radio_ifat_button:  ns.to_p 'readiness_assurance', 'shared', 'radio', 'ifat_button'

  c_shared_timer_show:  ns.to_p 'readiness_assurance', 'shared', 'timer', 'show'

  init: ->
    @_super()
    @csse            = @get('csse')
    @messages        = @get('messages')
    @pubsub          = @csse.pubsub
    @messages_loaded = false
    @timer_messages  = {}

  load_messages: ->
    return if @messages_loaded
    @messages.load room: @current_user_room()
    @messages_loaded = true

  # Casespace 'server_event' service methods.
  join_with_current_user: (args...) -> @csse.join_assignment_with_current_user(args...)
  current_user_room:      (args...) -> @csse.assignment_current_user_room(args...)
  phase_ownerable_room:   (args...) -> @csse.phase_ownerable_room(args...)

  leave_all_except_current_user_server_event_room: (args...) -> @csse.leave_all_except_assignment_current_user_room(args...)
  current_user_server_event_room:                  (args...) -> @csse.assignment_current_user_server_event_room(args...)

  # admin
  join_admin_room:             -> @csse.join room: @get_admin_room()
  leave_all_except_admin_room: -> @csse.leave_all(except: @get_admin_room())
  get_admin_room:              -> @csse.assignment_room('admin')

  join_timer_room: (model, options={}) ->
    room               = @pubsub.room_with_current_user(model)
    room_event         = 'timer'
    options.room       = room
    options.room_event = room_event
    @pubsub.join(options)
    {room, room_event}

  start_timers: (options) ->
    room      = options.room
    event     = @pubsub.client_event('timers')
    room_type = null
    @pubsub.message_to_rooms_members(event, room, {room_type})

  get_timer_message: (room)          -> @timer_messages[room]
  set_timer_message: (room, message) -> @timer_messages[room] = message

  tracker_room: -> @csse.assignment_room()

  tracker: ->
    room = @tracker_room()
    @pubsub.tracker({room})
