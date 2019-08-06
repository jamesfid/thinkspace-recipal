import ember from 'ember'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  get_new_messages:      (options={}) -> @get_messages('is_new', options)
  get_previous_messages: (options={}) -> @get_messages('is_previous', options)
  move_all_to_previous:  (rooms=null) -> @get_new_messages(rooms).forEach (message) -> message.set_previous()

  get_messages: (msg_prop, options) ->
    filter_only  = options.filter_only or false
    rooms        = ember.makeArray(options.room or options.rooms).compact()
    sort_by      = ember.makeArray(options.sort or ['date:desc'])
    sort_by_prop = @get_sort_by_property(sort_by)
    type_prop    = @get_message_store_filter_for_type()
    filter_prop  = @get_filter_property(type_prop, msg_prop, rooms)
    sort_prop    = @get_sort_property(filter_prop, sort_by_prop)
    messages     = if filter_only then @get(filter_prop) else @get(sort_prop)
    return messages if messages
    ember.defineProperty @, filter_prop, ember.computed.filter "#{type_prop}.@each.state", (message) -> @filter_messages(message, msg_prop, rooms)
    return @get(filter_prop) if filter_only
    @set(sort_by_prop, sort_by)  unless @get(sort_by_prop)
    ember.defineProperty @, sort_prop, ember.computed.sort filter_prop, sort_by_prop
    @get(sort_prop)

  get_filter_property: (type_prop, msg_prop, rooms) ->
    prop  = "_msg_filter_#{type_prop}_#{msg_prop}"
    if ember.isBlank(rooms) then "#{prop}_all" else "#{prop}_" + rooms.join(':')

  get_sort_by_property: (sort_by) -> "_msg_sort_by_#{sort_by}"

  get_sort_property: (filter_prop, sort_by_prop) -> "_msg_sort_#{sort_by_prop}_#{filter_prop}"

  filter_messages: (message, prop, filter_rooms=null) ->
    return false unless message.get(prop)
    return true  if ember.isBlank(filter_rooms)
    msg_rooms = message.get('rooms')
    return false if ember.isBlank(msg_rooms)
    msg_rooms = ember.makeArray(msg_rooms)
    @in_filter_rooms(filter_rooms, msg_rooms)

  in_filter_rooms: (filter_rooms, msg_rooms) ->
    return true if filter_rooms.contains(room) for room in msg_rooms
    false

  get_message_store_filter_for_type: ->
    type = @message_model_type
    prop = "_msg_store_filter_#{type}"
    return prop if ember.isPresent @get(prop)
    store  = totem_scope.get_store()
    filter = store.filter(type, (message) -> true)
    @set prop, filter
    prop
