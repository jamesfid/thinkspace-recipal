import ember  from 'ember'
import config from 'totem/config'
import logger from 'totem/logger'
import util   from 'totem/util'

class TotemLaterTimer
  constructor: (@obj, @fn, @interval) -> @timer = null
  start:  -> @timer = ember.run.later(@obj, @fn, @interval)
  cancel: -> ember.run.cancel(@timer)  if @timer

class TotemTimer
  constructor: (@options) ->
    @run_type = @options.run_type or 'later'
    delete(@options.run_type)
    @timers = []
  reset: ->
    @cancel()
    @start()
  start: ->
    return unless @options and @run_type
    switch @run_type
      when 'later'
        @add_later args[0], key, args[1]  for key, args of @options
  add_later: (obj, fn, interval) ->
    timer = new TotemLaterTimer(obj, fn, interval)
    timer.start()
    @timers.push timer
  cancel: ->
    for timer in @timers
      timer.cancel()
      timer = null
    @timers = []


session = (config and config.session_timeout) or {}

export default ember.Controller.extend
  totem_outlet_messages:             null
  seconds_remaining_before_sign_out: null
  timer_created_at_key:              'totem:session_timer_created_at'

  init: ->
    @_super()
    @setup_session_timeout()
    @bind_to_storage()

  setup_session_timeout: ->
    @timeout_time = session.time or 0          # session timeout after time
    @warning_time = session.warning_time or 0  # time to display warning page
    @timeout_time = @timeout_time * 1000 * 60 # convert minutes to milliseconds
    @warning_time = @warning_time * 1000 * 60 # convert minutes to milliseconds

    # # Override timeout values for testing.
    # @timeout_time = 10 * 1000  # session timeout after time (10 seconds)
    # @warning_time = 5 * 1000   # time to display warning page (5 seconds)

    @warning_decrement = session.warning_decrement_by or 1
    @warning_decrement = @warning_decrement * 1000 # convert seconds to milliseconds
    @warning_decrement = 1000  if @warning_decrement < 1000  # make decrement min of 1 second for practicality

    logger.debug "Config: Timeout=#{@timeout_time}  Warning=#{@warning_time}  DecBy=#{@warning_decrement}"  if logger.is_debug

    @warning_time = 0  if @timeout_time <= @warning_time

    if @timeout_time > 0 and @warning_time > 0
      @session_timer = new TotemTimer
        show_session_timeout_warning: [@, (@timeout_time - @warning_time)]
        sign_out_user:                [@, @timeout_time]

      @count_down_time = @warning_time / 1000
      if @count_down_time > 0 
        @count_down_timer = new TotemTimer
          decrement_count_down_time: [@, @warning_decrement]
        @decrement_by = @warning_decrement / 1000

    else if @timeout_time > 0
      @session_timer = new TotemTimer
        sign_out_user: [@, @timeout_time]

    else
      @session_timer = null

  cancel_session_timer: ->
    @session_timer.cancel()     if @session_timer
    @count_down_timer.cancel()  if @count_down_timer

  reset_session_timer: (options) ->
    return unless @session_timer
    logger.debug "Reset session timer: #{util.hh_ss_mm(new Date)}"  if logger.is_debug
    if options and options.stay_alive
      type   = @ns.to_p('user')
      action = 'stay_alive'
      # ## reset timer then send stay alive request ## #
      @reset_local_store()
      @session_timer.reset()
      @store.find(type, action: action).then null
      , (error) =>
        @totem_messages.api_failure error, model: type, action: action
    else
      @reset_local_store()
      @session_timer.reset()
    @count_down_timer.cancel()  if @count_down_timer

  reset_local_store: ->
    window.localStorage.setItem @get_timer_created_at_key(), new Date()

  show_session_timeout_warning: ->
    return unless ember.isPresent @get('session.user')
    logger.debug "Warn: #{util.hh_ss_mm(new Date)}"  if logger.is_debug
    message = session.warning_message or "Your session is about to timeout!"
    @totem_messages.warn message
    @totem_messages.message_outlet
      template_name:    'totem_message_outlet/session_timeout_warning'
      outlet_view:       'session_timeout_warning'
      outlet_controller: @
      outlet_messages:   message
    if @count_down_timer
      @set 'seconds_remaining_before_sign_out', @count_down_time
      @count_down_timer.reset()

  hide_session_timeout_warning: ->
    @totem_messages.hide_message_outlet()

  sign_out_user: ->
    logger.debug "Sign out user: #{util.hh_ss_mm(new Date)}"  if logger.is_debug
    @totem_messages.sign_out_user()

  decrement_count_down_time: ->
    time_remaining = @get 'seconds_remaining_before_sign_out'
    if (time_remaining -= @decrement_by) > 0
      @set 'seconds_remaining_before_sign_out', time_remaining
      @count_down_timer.reset()
    else
      @set 'seconds_remaining_before_sign_out', 'session timeout'
      @count_down_timer.cancel()

  get_timer_created_at_key: -> @get 'timer_created_at_key'

  bind_to_storage: ->
    $(window).bind 'storage', (e) =>
      if e.originalEvent.key == @get_timer_created_at_key() or e.key == @get_timer_created_at_key()
        @reset_session_timer()
        @hide_session_timeout_warning()
