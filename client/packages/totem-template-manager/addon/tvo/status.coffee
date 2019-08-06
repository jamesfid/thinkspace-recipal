import ember from 'ember'
import base  from 'totem-template-manager/tvo/status_base'

# tvo.status[key] = status_collection instance
#   status_collection['status_map'] #=> key: guid, value: source_status instance
# tvo.status.all_valid() returns a promise that resolves when all are valid or rejects when any are invalid.
#   - currently both the resolve and reject return the POJO: {is_valid: [true|false], status_messages: [msg1, msg2, ...]}

export default base.extend
  init: ->
    @_super()
    @init_status_values()
    @set 'collection_keys', []

  get_path: (key) -> "#{@tvo_property}.#{key}"

  get_value: (key) -> @tvo.get_path_value @get_path(key)
  
  get_collection_keys: -> @get 'collection_keys'

  set_value: (key) ->
    path   = @get_path(key)
    status = @get_value(key)
    unless status
      @tvo.set_path_value path, @new_status_collection()
      @get_collection_keys().push(key)
    path

  register_validation: (key, source, fn) ->
    @set_value(key)
    @get_value(key).register_validation(source, fn)

  all_valid: ->
    new ember.RSVP.Promise (resolve, reject) =>
      status_instances = @get_collection_keys().map (key) => @get_value(key)
      @set_status_values(status_instances).then (status) =>
        if status.is_valid then resolve(status) else reject(status)
          
  edit_on:  -> @set 'is_edit', true
  edit_off: -> @set 'is_edit', false

  new_status_collection: -> @get('status_collection').create()

  toString: -> 'TvoStatus'

  # ###
  # ### Status Collection Object.
  # ###

  status_collection: base.extend
    init: ->
      @_super()
      @init_status_values()
      @set 'status_map', ember.Map.create()
      # Status values for all the 'by validate' guids for a key e.g. 'elements'.
      # Represents the real-time values after each 'validate' call.
      @set 'count', {}

    get_status_map: -> @get('status_map')

    register_validation: (source, fn) ->
      source_status = @new_source_status()
      source_status.set_callback(source, fn)
      @set_source_status(source, source_status)

    validate: (source, group_guid=null) ->
      new ember.RSVP.Promise (resolve, reject) =>
        return resolve()  unless source.get('is_validation_mixin_included') == true
        source_status = @new_source_status()
        source.validate().then =>
          source_status.set_is_valid(true)
          @set_validate_status source, source_status, group_guid
          resolve()
        , (error) =>
          source_status.set_is_valid(false)
          # source_status.set_error(error)
          @set_validate_status source, source_status, group_guid
          reject()

    set_validate_status: (source, source_status, group_guid) ->
      source_status.set_by_validate()
      @set_source_status(source, source_status, group_guid)
      @update_overall_validate_status_counts()

    update_overall_validate_status_counts: ->
      status  = @get_status_map()
      valid   = 0
      invalid = 0
      @get_status_map().forEach (source_status) =>
        if source_status.is_by_validate()
          if source_status.get_is_valid() then valid += 1 else invalid += 1
      @set 'count.valid', valid
      @set 'count.invalid', invalid
      @set_is_valid (invalid < 1)

    set_source_status: (source, source_status, group_guid=null) ->
      guid = group_guid or @get_source_guid(source)
      @get_status_map().set guid, source_status

    set_status_values: ->
      status_instances = []
      @get_status_map().forEach (status) => status_instances.push(status)
      @_super(status_instances)

    get_source_guid: (source) -> ember.guidFor(source) or 'bad_status_guid'

    new_source_status: -> @get('source_status').create()

    toString: -> 'TvoStatusCollection'

    # ####
    # #### Each Source's Status.
    # ####

    source_status: base.extend
      init: ->
        @_super()
        @init_status_values()
        @set 'by_validate', false
        @set 'by_callback', false
        @set 'callback_source', null
        @set 'callback_fn', null

      get_callback_source: -> @get('callback_source')
      get_callback_fn:     -> @get('callback_fn')

      is_by_callback:  -> @get('by_callback') == true
      is_by_validate:  -> @get('by_validate') == true
      set_by_validate: -> @set 'by_validate', true

      set_callback: (source, fn) ->
        @set 'by_callback', true
        @set 'callback_source', source
        @set 'callback_fn', fn

      set_status_values: ->
        new ember.RSVP.Promise (resolve, reject) =>
          return resolve() if @is_by_validate()
          source = @get_callback_source()
          fn     = @get_callback_fn()
          unless (source and fn)
            @set_is_valid(false)
            @set_status_messages('missing source or fn')
            return resolve()
          unless typeof source[fn] == 'function'
            @set_is_valid(false)
            @set_status_messages("[#{fn}] is not a function for [#{source.toString()}]")
            return resolve()
          callback_status = @get('callback_status').create()
          source[fn](callback_status).then =>
            @set_callback_status_values(callback_status)
            resolve()
          , =>
            @set_is_valid(false)
            @set_status_messages("[#{fn}] function for [#{source.toString()}] had an error.")
            resolve()

      set_callback_status_values: (status) ->
        @set_is_valid         status.get_is_valid()
        @set_valid_count      status.get_valid_count()
        @set_invalid_count    status.get_invalid_count()
        @set_status_messages  status.get_status_messages()

      callback_status: base.extend
        init: ->
          @_super()
          @init_status_values()

        increment_valid_count:   -> @incrementProperty 'valid_count'
        increment_invalid_count: -> @incrementProperty 'invalid_count'

      toString: -> 'TvoSourceStatus'
