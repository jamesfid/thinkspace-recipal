import ember from 'ember'

export default ember.Mixin.create

  join: (options={}) ->
    return unless @is_active
    room       = options.room
    source     = options.source or @
    callback   = options.callback or 'handle_server_event'
    room_event = options.room_event or 'server_event'
    @pubsub.join {room, source, callback, room_event}

  leave: (options={}) ->
    return unless @is_active
    rooms = options.rooms
    return unless rooms
    room_type = options.room_type
    @pubsub.leave({rooms, room_type})

  leave_all: (options={}) -> @is_active and @pubsub.leave_all(options)

  # ###
  # ### Room Helpers.
  # ###

  assignment_room: (args...)              -> @pubsub.room_for(@get_assignment(), args...)
  assignment_ownerable_room: (args...)    -> @pubsub.room_with_ownerable(@get_assignment(), args...)
  assignment_current_user_room: (args...) -> @pubsub.room_with_current_user(@get_assignment(), args...)
  phase_room: (args...)                   -> @pubsub.room_for(@get_phase(), args...)
  phase_ownerable_room: (args...)         -> @pubsub.room_with_ownerable(@get_phase(), args...)
  phase_current_user_room: (args...)      -> @pubsub.room_with_current_user(@get_phase(), args...)

  server_event_room: 'server_event'
  assignment_current_user_server_event_room: -> @assignment_current_user_room(@server_event_room)

  # ###
  # ### Join Helpers.
  # ###

  join_assignment: (options={})                   -> options.room = @assignment_room();              @join(options)
  join_assignment_with_ownerable: (options={})    -> options.room = @assignment_ownerable_room();    @join(options)
  join_assignment_with_current_user: (options={}) -> options.room = @assignment_current_user_room(); @join(options)
  join_phase: (options={})                        -> options.room = @phase_room();                   @join(options)
  join_phase_with_ownerable: (options={})         -> options.room = @phase_ownerable_room();         @join(options)
  join_phase_with_current_user: (options={})      -> options.room = @phase_current_user_room();      @join(options)

  join_phase_or_assignment: (options={}) -> if ember.isPresent(@get_phase()) then join_phase(options) else join_assignment(options)

  # ###
  # ### Leave Helpers.
  # ###

  leave_all_except_assignment_room: (options={})              -> options.except = @assignment_room();              @leave_all(options)
  leave_all_except_assignment_ownerable_room: (options={})    -> options.except = @assignment_ownerable_room();    @leave_all(options)
  leave_all_except_assignment_current_user_room: (options={}) -> options.except = @assignment_current_user_room(); @leave_all(options)
  leave_all_except_phase_room: (options={})                   -> options.except = @phase_room();                   @leave_all(options)
  leave_all_except_phase_ownerable_room: (options={})         -> options.except = @phase_ownerable_room();         @leave_all(options)
  leave_all_except_phase_current_user_room: (options={})      -> options.except = @phase_current_user_room();      @leave_all(options)
