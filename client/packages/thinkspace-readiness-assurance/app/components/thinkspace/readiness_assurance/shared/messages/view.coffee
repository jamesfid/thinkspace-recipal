import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  init: ->
    @_super()
    @messages     = @ra.get('messages')
    @filter_rooms = @rooms || @ra.current_user_room()

  new_messages:      ember.computed -> @messages.get_new_messages(rooms: @filter_rooms)
  previous_messages: ember.computed -> @messages.get_previous_messages(rooms: @filter_rooms)
  has_messages:      ember.computed.or 'new_messages.length', 'previous_messages.length'

  show_new:      false
  show_previous: false

  actions:
    mark_previous: (msg) ->
      msg.set_previous()
      @set_show_new()

    mark_all_previous: ->
      @messages.move_all_to_previous(@filter_rooms)
      @set_show_new()

    toggle_new:      -> @toggleProperty('show_new'); return
    toggle_previous: -> @toggleProperty('show_previous'); return

  set_show_new: -> @set 'show_new', false if @get('new_messages.length') == 0
  
