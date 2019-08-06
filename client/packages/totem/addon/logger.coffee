import {env}  from 'totem/config'
import config from 'totem/config'

logger = config.logger or {}

class Logger

  @env_log_level = null

  @log_values =
    none:    0
    info:    1
    warn:    2
    error:   3
    debug:   4
    verbose: 5
    all:     6

  @log_value  = null
  @is_info    = null
  @is_warn    = null
  @is_error   = null
  @is_debug   = null
  @is_verbose = null
  @is_all     = null

  @is_trace = null
  @is_rest  = null  # log totem_scope rest_serializer and rest_adapter calls

  @set_log_trace: (value = logger.log_trace) -> @is_trace = value
  @set_log_rest:  (value = logger.log_rest)  -> @is_rest  = value

  @set_log_level: (@env_log_level = logger.log_level) ->
    @log_value   = @log_values[@env_log_level] ? 0
    @is_info     = @log_values.info <= @log_value or @is_development()
    @is_warn     = (@log_values.warn <= @log_value) or @is_development()
    @is_error    = (@log_values.error <= @log_value) or @is_development()
    @is_debug    = @log_values.debug <= @log_value
    @is_verbose  = @log_values.verbose <= @log_value
    @is_all      = @log_values.all <= @log_value
    @set_log_trace()
    @set_log_rest()
    @log_test()  if @is_verbose

  # Log based on log level
  @info:    -> @_log_args('info',    arguments)  if @is_info
  @warn:    -> @_log_args('warn',    arguments)  if @is_warn
  @error:   -> @_log_args('error',   arguments)  if @is_error
  @debug:   -> @_log_args('debug',   arguments)  if @is_debug
  @verbose: -> @_log_args('verbose', arguments)  if @is_verbose

  # Log always
  @log: -> @_log_args('log', arguments)

  # Log rest serializer/adapter calls (@is_rest = true|false)
  @rest: -> @_log_args('rest', arguments)

  # Log based on trace on/off (e.g. @is_trace = true|false)
  @trace: ->
    object = arguments[0]  # by convention the first argument is a reference to the caller's 'this'
    name   = null
    if object and object.toString
      name = object.toString()
      args = [].splice.call(arguments,0)  # turn into a functional array
      args.shift()        # remove the object at [0]
      args.unshift(name)  # put the name first
      args.push object    # add object at end
    @_log_args('trace', args)  if @log_trace_entry(name)

  # If @is_trace value set to a string, then first argument must match (igore case)
  @log_trace_entry: (name) ->
    return true if @is_trace == true
    name and name.match(new RegExp(@is_trace, 'i'))

  @is_development: -> env.environment == 'development'

  @log_test: ->
    @_log_args 'test', ">Log Test: [#{@env_log_level}] (log level #{@log_value}) -------------------"
    @info    "INFO"
    @warn    "WARN"
    @error   "ERROR"
    @debug   "DEBUG"
    @verbose "VERBOSE"
    @_log_args 'test', "<Log Test: [#{@env_log_level}] (log level #{@log_value}) -------------------"
    @_log_args 'test', "TRACE=#{@is_trace}"

  @_log_args: (level, args) ->

    message  = args[0]

    if typeof(message) == 'string' and args.length == 1
      switch level
        when 'error' then console.error "[#{level}]", message
        when 'warn'  then console.warn  "[#{level}]", message
        when 'info'  then console.info  "[#{level}]", message
        when 'trace' then console.info  "[#{level}]", message
        else              console.log   "[#{level}]", message
      return

    if typeof(message) == 'object'
      log_args = [].splice.call(message,0)
      message  = log_args.shift()
      if typeof(message) == 'string'
        switch level
          when 'error' then console.error "[#{level}]", message, log_args
          when 'warn'  then console.warn  "[#{level}]", message, log_args
          when 'info'  then console.info  "[#{level}]", message, log_args
          when 'trace' then console.info  "[#{level}]", message, log_args
          else              console.log   "[#{level}]", message, log_args
        return

    switch level
      when 'error' then console.error "[#{level}]", args
      when 'warn'  then console.warn  "[#{level}]", args
      when 'info'  then console.info  "[#{level}]", args
      when 'trace' then console.info  "[#{level}]", args
      else              console.log   "[#{level}]", args

Logger.set_log_level()

export default Logger