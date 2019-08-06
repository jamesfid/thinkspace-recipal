import ember             from 'ember'
import ds                from 'ember-data'
import ajax              from 'totem/ajax'
import cache_image       from 'totem/cache_image'
import pagination_array  from 'totem-application/pagination/array'
import pagination_object from 'totem-application/pagination/object'

# ###
# ### Totem Cache (tc)
# ### Specification: https://github.com/sixthedge/cnc-client/wiki/%5BService%5D-Totem-Cache-(TC)
totem_cache_module = ember.Object.extend

  cache:     null
  container: null

  init: ->
    @set 'cache', ember.Object.create()
    @ajax  = ajax
    @image = cache_image.create(tc: @)

  # ### Finders
  all: (type, options={})  ->
    @deprecation "Using tc's `all` when you should be using `peek_all`."
    @peek_all(type)

  find: (type, id=null, options={}) ->
    if ember.isPresent(id)
      @deprecation "Using tc's `find` when you should be using `find_record`."
      @find_record(type, id, options)
    else
      @deprecation "Using tc's `find` when you should be using `find_all`."
      @find_all(type, options)

  find_record: (type, id, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      resolve @get_store().find(type, id, options)
    , (error) =>
      @warn("Error in `find_record` when querying for [#{type}] id: [#{id}] with: ", options)
      reject(error)

  find_all: (type, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if @cache_contains(type) and !options.reload
        resolve @get_from_cache(type)
      else
        @get_store().find(type, options).then (results) =>
          @set_cache type, results
          resolve(results)
    , (error) =>
      @warn("Error in `find_all` when querying for [#{type}] with: ", options)
      reject(error)

  peek_record: (type, id) -> @get_store().getById(type, id)

  peek_all: (type) -> @store.all(type)

  query_record: (type, query) -> console.error "[tc] Has not defined `query_record` yet."

  query: (type, query, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      # Extract relevant keys, then remove from payload so they are not sent.
      action = query.action or ''
      verb   = query.verb or 'GET'
      id     = query.id or null
      delete query.action
      delete query.verb
      delete query.id

      ajax_options =
        model:  type
        data:   query
        action: action
        verb:   verb
        id:     id

      # If a payload type is specified, extract that as the records to return.
      type = options.payload_type if ember.isPresent(options.payload_type)

      ajax.object(ajax_options).then (payload) =>
        return resolve([]) if payload == undefined or ember.isEmpty(ember.keys(payload)) # Support `controller_render_no_content`
        if ember.isPresent(payload.links)
          array = @get_paginated_array(type, payload)
          resolve(array)
        else
          options.skip_ns = true
          if options.multitype
            hash = {}
            for key, value of payload
              json = {}
              json[key] = value
              type      = ember.Inflector.inflector.singularize(key)
              hash[key] = ajax.normalize_and_push_payload(type, json, options)
            resolve(hash)
          else
            records = ajax.normalize_and_push_payload(type, payload, options)

          resolve(records)
      , (error) =>
        @warn "ajax.object failed for query of: ", query
        reject(error)
    , (error) =>
        @warn "Could not process query of: ", query
        reject(error)

  # ### Cache
  get_cache:      -> @get 'cache'
  set_cache:      (key, records) -> @get_cache().set key, records
  get_from_cache: (key) -> @get_cache().get(key)
  cache_contains: (key) -> ember.isPresent(@get_from_cache(key))

  # ### Pagination
  add_pagination_to_query: (query, number, count=15) ->
    query.page = @get_pagination_options(number, count)
    query

  get_default_pagination_query: ->
    query      = {}
    query.page = @get_pagination_options(1)
    query

  get_pagination_options: (number, count=15) ->
    {number: number, count: count}

  get_paginated_array: (type, payload) ->
    array = pagination_array.create()
    array.process_pagination_payload(payload, type)
    array

  # ### Filter
  add_filter_to_query: (query, filter) ->
    query.filter = JSON.stringify(filter)
    query

  get_filter_array: (method, values) ->
    [{method: method, values: values}]

  # ### Helpers
  warn:      (message, args...) -> console.warn "[tc] WARN: #{message}", args
  get_store:     -> @get_container().lookup('store:main')
  get_container: -> @get 'container'
  set_container: (container) -> @set 'container', container
  deprecation: (message) -> console.warn "[tc] DEPRECATION: #{message}"

export default totem_cache_module.create()  # Create the object to be registered/injected.
