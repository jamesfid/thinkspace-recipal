import ember  from 'ember'
import ds     from 'ember-data'
import config from 'totem/config'
import ns     from 'totem/ns'

class Ajax

  setup_complete: false

  get_container: -> @container
  set_container: (container) -> @container = container

  setup: ->
    @adapter        = @container.lookup('adapter:application')
    @store          = @container.lookup('store:main')
    @totem_error    = @container.lookup('totem:error')
    @totem_scope    = @container.lookup('totem:scope')
    @totem_messages = @container.lookup('totem:messages')
    @json_transform = @container.lookup('transform:json-api-models')
    ## TODO: Fix this typo. When it is corrected, tc filtering on the resources#index page reports that '_this.totem_messages is undefined' any request is made.
    @add_jquery_binary_tranport() unless @setup_comlete
    @setup_comlete = true

  get_auth_header: ->
    session = @get_container().lookup('simple-auth-session:main')
    token   = session.get('secure.token')
    email   = session.get('secure.email')
    @error("Session token is blank.") if ember.isBlank(token)
    @error("Session email is blank.") if ember.isBlank(email)
    'Token token' + '="' + token + '", ' + 'email' + '="' + email + '"'

  add_jquery_binary_tranport: ->
    ember.$.ajaxTransport '+binary', (options, original_options, jqXHR) ->
      if options.dataType and options.dataType == 'binary'
        return
          abort: ->
            jqXHR.abort()
          send: (headers, callback) ->
            xhr       = new XMLHttpRequest()
            url       = options.url
            type      = options.type
            is_async  = true
            dataType  = 'blob'
            data      = options.data or null
            xhr.addEventListener 'load', ->
              data = {}
              data[options.dataType] = xhr.response
              callback(xhr.status, xhr.statusText, data, xhr.getAllResponseHeaders())
            xhr.open(type, url, is_async)
            xhr.setRequestHeader('Authorization', original_options.auth_header)
            xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8')
            xhr.responseType = dataType
            xhr.processData  = false
            xhr.send(data)

  binary: (options) ->
    @setup() unless @setup_complete
    session = @get_container().lookup('simple-auth-session:main')
    token   = session.get('secure.token')
    email   = session.get('secure.email')
    @error("Session token is blank.") if ember.isBlank(token)
    @error("Session email is blank.") if ember.isBlank(email)
    promise = new ember.RSVP.Promise (resolve, reject) =>
      query             = @build_query(options)
      query.auth_header = @get_auth_header()
      query.dataType    = 'binary'
      query.success     = (result) =>
        resolve(result)
      query.error = (error) =>
        reject(error)
      ember.$.ajax(query)
    return ds.PromiseObject.create promise: promise

  array: (options) ->
    @setup()  unless @setup_complete
    promise = new ember.RSVP.Promise (resolve, reject) =>
      query = @build_query(options)
      query.success = (result) =>
        @totem_messages.api_success source: 'ajax.array', model: (options.model or options.url), action: options.action  unless options.skip_message
        resolve(result)
      query.error = (error) =>
        @totem_messages.api_failure error, source: 'ajax.array', model: (options.model or options.url), action: options.action  unless options.skip_message
        reject(error)
      ember.$.ajax(query)
    return ds.PromiseArray.create promise: promise

  object: (options) ->
    @setup()  unless @setup_complete
    promise = new ember.RSVP.Promise (resolve, reject) =>
      query = @build_query(options)
      query.success = (result) =>
        @totem_messages.api_success source: 'ajax.object', model: (options.model or options.url), action: options.action  unless options.skip_message
        resolve(result)
      query.error = (error) =>
        @totem_messages.api_failure error, source: 'ajax.object', model: (options.model or options.url), action: options.action  unless options.skip_message
        reject(error)
      ember.$.ajax(query)
    return ds.PromiseObject.create promise: promise

  find_many: (options) ->
    @setup() unless @setup_complete
    promise = new ember.RSVP.Promise (resolve, reject) =>
      results = {}
      @object(options).then (payload) =>
        for type of payload
          model  = ember.Inflector.inflector.singularize(type)
          values = ember.makeArray(payload[type])
          ids    = values.mapBy('id')
          @store.pushPayload(model, payload)
          models = @store.all(model).filter (model) =>
            ids.contains parseInt(model.get('id'))
          results[type] = models
        resolve(results)

  adapter_model_url: (options) ->
    @setup()  unless @setup_complete
    options.action ?= ''
    @build_query(options).url

  adapter_host: ->
    @setup()  unless @setup_complete
    @adapter.get('host')

  build_query: (options) ->
    verb       = options.verb or 'GET'
    action     = options.action
    model      = options.model
    id         = options.id
    data       = options.data or {}
    url        = options.url

    @error "Either [model] or [url] options must be passed.", options  unless (model or url)
    if url
      @error "[model], [action] and [id] are ignored when the url is passed; remove them.", options  if (model or action or id)
    else
      @error "Model is blank.", options   unless model
      @error "Action is blank.", options  unless action?  # allow an empty string

    query             = {}
    query.type        = verb
    query.dataType    = 'json'
    query.contentType = 'application/json; charset=utf-8'
    query.timeout     = config.ajax_timeout  if config.ajax_timeout

    # When an URL is passed, it is used 'as-is'; e.g. assumes it has any ids, actions, etc. already added.
    # Otherwise, the URL is built using the model, action and id options.
    type_key = null

    if url
      # Passing in a 'parentURL' (from urlPrefix() without params e.g. returns host/namepsace -> localhost:3000/api).
      # The parentURL is not used for absolute urls (e.g. start with '/'') or urls starting with 'http(s)'.
      # Need when running via ember-cli where the host is 'localhost:4200'.
      url = @adapter.urlPrefix(url, @adapter.urlPrefix())
    else
      switch typeof(model)
        when 'string'
          # String model class name.
          model_class = @totem_scope.model_class_from_string(model)
          @error "Model class for [#{model}] not found.", options  unless model_class
          type_key = @totem_scope.model_class_type_key(model_class)
          @totem_scope.add_auth_to_query(model_class, data)
        when 'object'
          # Model instance.
          type_key = @totem_scope.record_type_key(model)
          @totem_scope.add_auth_to_query(model, data)
        else
          @error "Unknown model object (not a string or object).", options

      @error "Model typeKey is blank.", options  unless type_key

      url  = @adapter.buildURL type_key, id, verb
      url += '/' + action if action

    query.data = data
    # GET either needs processData: false or to not be stringified.
    query.data = @stringify query.data unless @query_is_get(query)
    query.url  = url

    query

  stringify: (obj) ->
    JSON.stringify(obj)

  query_is_get: (query) ->
    query.type == 'GET' or query.type == 'get'

  error: (message, options=null) ->
    message ?= ''
    message += " [options: #{@stringify(options)}]"  if options
    @totem_error.throw @, "totem.ajax error: #{message}"

  normalize_and_push_payload: (type, payload, options={}) ->
    @setup() unless @setup_complete
    # Do not use ns.to_p
    if options.skip_ns
      payload_type = ember.Inflector.inflector.pluralize(type)
    else
      payload_type = ns.to_p(ember.Inflector.inflector.pluralize(type))
      type         = ns.to_p(type)

    # Expect a singular key.
    if options.single
      records = ember.makeArray(payload[type])
      delete payload[type]
    else
      records = payload[payload_type]
      delete payload[payload_type]

    return []    unless ember.isPresent(records)
    normalized   = records.map (record) => @store.normalize(type, record)
    records      = @store.pushMany(type, normalized)
    @store.pushPayload(payload) unless ember.isEmpty(ember.keys(payload)) or options.skip_extra_records
    records = records.get('firstObject') if options.single
    records

  extract_included_records: (payload, options={}) ->
    key    = options.key or 'included'
    models = payload[key]
    delete payload[key]
    @json_transform.deserialize(models)

export default new Ajax
