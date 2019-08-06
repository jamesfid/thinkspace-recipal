import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  message: null

  willInsertElement: -> @setup()

  setup: ->
    model         = @get('model')
    @room_options = @ra.join_timer_room model,
      source:                   @
      callback:                 'handle_timer'
      after_authorize_callback: 'start_timers_callback'
    previous = @ra.get_timer_message(@room_options.room)
    @set 'message', previous if ember.isPresent(previous)

  handle_timer: (data={}) ->
    console.info 'handle_timer:', data
    message = @get_message(data)
    @ra.set_timer_message(@room_options.room, message)
    @set 'message', message

  get_message: (data) ->
    data_msg = data.message
    prefix   = if data.n == (data.of-1) then 'in less than' else 'in about'
    message  = prefix + " #{data.units} #{data.label}"
    message  = "#{data_msg} (#{message})." if ember.isPresent(data_msg)
    message

  start_timers_callback: (options) -> @ra.start_timers(options)
