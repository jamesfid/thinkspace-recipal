import ember  from 'ember'
import logger from 'totem/logger'

totem_scope_module = ember.Object.extend
  toString: -> 'totem_scope'

  container: null
  get_container:             -> @get 'container'
  set_container: (container) -> @set 'container', container
  container_lookup: (key)    -> @get_container().lookup(key)

  # References the application's data store.
  data_store: null
  get_store: ->
    store = @get('data_store')
    return store if store
    store = @container_lookup('store:main')
    @set 'data_store', store
    store

# ###
# ### User 'view' mode.
# ###

totem_scope_module.reopen
  # The view capability used by view generators and templates.
  # Must be manually turned on/off.
  is_read_only: false
  is_disabled:  false
  is_view_only: ember.computed.or 'is_read_only', 'is_disabled'  # single convience property that or's the granular values

  read_only_on:  -> @set 'is_read_only', true
  read_only_off: -> @set 'is_read_only', false
  disabled_on:   -> @set 'is_disabled',  true
  disabled_off:  -> @set 'is_disabled',  false
  view_only_on: ->
    @read_only_on()
    @disabled_on()
  view_only_off: ->
    @read_only_off()
    @disabled_off()

# ###
# ### Path ids.
# ###

totem_scope_module.reopen
  # Contains all paths and ids that are used in filters; path_ids[path-name] = [ids].
  path_ids:     {}

  get_path_ids: (path) -> @get "path_ids.#{path}"

  # Set the path ids and send an ids change notification.
  set_path_ids: (path, ids) ->
    path and @set "path_ids.#{path}", @make_ids_array(ids)
    @notify_path_ids_property_change()
    
  reset_all_ids:         -> @set 'path_ids', {}
  reset_path_ids: (path) -> @set_path_ids path, null

  notify_path_ids_property_change: -> @notifyPropertyChange('path_ids')

  path_ids_blank:   (path) -> path and @is_blank(@get_path_ids path)
  path_ids_present: (path) -> not @path_ids_blank(path)

  can_view_path_id: (path, id) ->
    return false unless (path and id)
    ids = @get_path_ids(path) or []
    id in ids

  # Map of each path to the filter attribute(s) on a record.  Typically, this will be the same as the ownerable
  # type and id attributes, but if different (e.g. want to filter on just 'user_id'), it can be set for a path.
  # The path's type and id attributes are set as: path_to_attrs.path-name = {type: type-attr, id: id-attr}.
  # 'Get' returns the specific path's type/id or will default to the 'ownerable' type/id (either is set or will be the default).
  path_to_attrs: {}
  get_path_type_attr: (path=null) -> (path and @get "path_to_attrs.#{path}.type") or @get_ownerable_type_attr()
  get_path_id_attr:   (path=null) -> (path and @get "path_to_attrs.#{path}.id")   or @get_ownerable_id_attr()
  set_path_attrs: (path, attrs)   -> path and (@set "path_to_attrs.#{path}", attrs)

# ###
# ### Current path and ids.
# ###

totem_scope_module.reopen
  # Current path is used to return ids from the 'path_ids' object e.g. path_ids[current_path].
  # The current path ids are used by the record association filters.
  # Typically, the current path (and ids) are set when setting the 'ownerable' but
  # can be manually set to any path/ids.
  current_path: null

  get_current_path: -> @get('current_path')
  get_current_ids:  -> @get_path_ids @get_current_path()

  set_current_path: (path=null) -> @set 'current_path', path

  # Current ids represent the ids in path_ids[current_path] (e.g. not a current_ids property).
  # Anytime the 'path_ids' are set, an ids change notification is sent.
  set_current_ids: (ids) -> @set_path_ids(@get_current_path(), ids)

  # Set the current path then set path_ids[current_path] = ids.
  set_current_path_and_ids: (path, ids) ->
    @set_current_path(path)
    @set_current_ids(ids)

  # Change the current path value.
  # If path is already the current path then return, else since a path change, notify the ids have changed.
  change_current_path: (path=null) ->
    return if @get_current_path() == path
    @set_current_path(path)
    @notify_path_ids_property_change()

  current_path_blank:   -> not @get_current_path()
  current_path_present: -> not @current_path_blank()
  current_ids_blank:    -> not @path_ids_blank(@get_current_path())
  current_ids_present:  -> not @current_ids_blank()

# ###
# ### Current user and current user id.
# ###

totem_scope_module.reopen
  current_user:    null
  current_user_id: null
  no_current_user: ember.computed.none  'current_user'

  # Convience fucntions to identify if the current user has been set.
  current_user_blank:   -> @get('no_current_user')
  current_user_present: -> not @current_user_blank()

  get_current_user: ->
    @set_current_user()  if @current_user_blank()
    @get('current_user')

  get_current_user_id: ->
    @set_current_user()  if @current_user_blank()
    @get('current_user_id')

  set_current_user: (user) ->
    if user then id = parseInt(user.get('id')) else id = null
    @set 'current_user', user
    @set 'current_user_id', id

  get_current_user_path: -> @get_record_path @get_current_user()
  get_current_user_type: -> @get_current_user_path()

# ###
# ### User convience functions.
# ###

totem_scope_module.reopen
  # Users are the typical case and these functions are conviences to the 'current' path/ids functions.

  # Computed property that templates can use to test if user ids are blank e.g. whether viewing
  # a user that is not the current user (user ids = [current user id] is also considered blank).
  view_user_ids_blank: ember.computed 'path_ids', 'current_user_id', -> @is_user_ids_current_user()

  # Alias computed property for 'view_user_ids_blank'.
  view_user_is_current_user: ember.computed.reads 'view_user_ids_blank'

  # The users' path will be created from the current_user if not populated.
  # It has many references so create once and store it rather than at each request.
  user_ids_path: null
  get_user_ids_path: -> @get('user_ids_path') or @set_user_ids_path()
  set_user_ids_path: (user=@get_current_user()) ->
    @set 'user_ids_path', @get_record_path(user)
    @get 'user_ids_path'

  get_user_ids: -> @get_path_ids @get_user_ids_path()

  is_user_ids_current_path: -> @current_path_blank() or @get_current_path() == @get_user_ids_path()

  # Set the user's path to filter on a single attribute (e.g. 'user_id') when does not have ownerable polymorphic.
  set_user_ids_path_attr: (attr='user_id') ->
    @set_path_attrs @get_user_ids_path(), {id: attr}

  is_user_ids_current_user: ->
    ids = @get_user_ids()
    return true unless ids  # if user ids have not been set yet, then is the current user
    ids.get('length') == 1 and ids.objectAt(0) == @get_current_user_id()

# ###
# ### Record association filters.
# ###

totem_scope_module.reopen
  # Filter functions called via totem_associations' filters.

  # Filter records based on current path and ids.
  # If the current_path is not set, default to the users path.
  can_view_record_current_path_id: (record) ->
    return false unless record
    path = @get_current_path() or @get_user_ids_path()
    if path == @get_user_ids_path()
      @can_view_record_user_id(record)  # users have special conditions e.g. allows matching current user id
    else
      return false if @record_is_deleted(record)
      id_attr = @get_path_id_attr(path)
      @valid_record_path_type(path, record) and @can_view_path_id(path, record.get(id_attr))

  # Filter function for users.
  # A common use of filters is to filter on the current user, therefore, if the users' path ids are blank,
  # defaults to matching the current_user id and allows filtering on current user before any paths/ids are set.
  # This function may be called by the totem_associations' filter function when filter: 'users' is used,
  # so must be capable to be called with just the record.
  can_view_record_user_id: (record) ->
    return false unless record
    return false if @record_is_deleted(record)
    path    = @get_user_ids_path()
    id_attr = @get_path_id_attr(path)
    id      = record.get(id_attr)
    return false unless id
    return false unless @valid_record_path_type(path, record)
    ids = @get_path_ids(path)
    unless ids
      current_user_id = @get_current_user_id()
      ids = (current_user_id and [current_user_id]) or []
    id in ids

  # Record's polymorphic 'type' value must match the path.
  valid_record_path_type: (path, record) ->
    type_attr = @get_path_type_attr(path)
    return true unless type_attr  # if type attr is blank (manually set to blank), no record type is checked and is valid
    type = record.get(type_attr)
    return false unless type
    path == @rails_polymorphic_type_to_path(type)

  # Convert a rails polymorphic model type 'attribute' to a path e.g. Some::Module::Model -> some/module/model
  rails_polymorphic_type_to_path: (type) ->
    type.underscore().replace(/::/g,'/')

  record_is_deleted: (record) ->
    record.get('isDeleted') or record.get('isDestroyed') or record.get('isDestroying') 

# ###
# ### User Data Action.
# ###

totem_scope_module.reopen
  # The server's controller 'action' to be called to return user based data (e.g. user or team).
  user_data_action: (record) -> (record.user_data_action and record.user_data_action()) or 'view'

  # Provide a sub-action name for saving viewed user ids and send to server for getting data.
  sub_action: null
  get_sub_action:            -> @get 'sub_action'
  set_sub_action: (sub=null) -> @set 'sub_action', sub

# ###
# ### Record Helpers
# ###

totem_scope_module.reopen
  get_view_query: (record, options={}) ->
    view_ids = ember.makeArray(options.view_ids or @get_ownerable_id())
    query =
      verb:       options.verb   or 'post'
      action:     options.action or @user_data_action(record)
      id:         options.id     or record.get('id')
      auth:
        sub_action: options.sub_action or @get_sub_action()
        view_ids:   view_ids
        view_type:  options.view_type or @get_ownerable_type()
    @add_authable_to_query(query, options.authable)
    @add_ownerable_to_query(query, options.ownerable)
    query

  # Return a query options object to load a record's unviewed ids.
  # Returns null if all ids are loaded.
  get_unviewed_query: (record, options={}) ->
    unviewed_ids = @get_unviewed_record_path_ids(record, options)
    @set_viewed_record_path_ids(record, options)  unless options.set_viewed == false
    return null if @is_blank(unviewed_ids)
    query =
      verb:       options.verb   or 'post'
      action:     options.action or @user_data_action(record)
      id:         options.id     or record.get('id')
      auth:
        sub_action: options.sub_action or @get_sub_action()
        view_ids:   unviewed_ids
        view_type:  @get_ownerable_type()
    @add_auth_to_query(record, query)
    query

  # Set the current path and ids from the record.
  current_path_and_ids_to_record: (record, options={}) ->
    @set_current_path_and_ids @get_record_path(record), record.get('id')
    @set_sub_action(options.sub_action)  if options.sub_action

  # Return a record's type key to use in a store.find() or model_type.
  record_type_key: (record) -> record.constructor.typeKey

  # Return a model class from a string that has the 'model_class.typeKey' set.
  # The 'store.modelFor' will normalize the string, so both a path (e.g. my/namespace/path/model)
  # or a model name (e.g. App.My.Namespace.Path.Model) will work.
  model_class_from_string: (string)   ->  @get_store().modelFor(string)
  model_class_type_key: (model_class) ->  ember.get(model_class, 'typeKey')

  # Return a records's path by converting its type key to a path.
  get_record_path: (record) ->
    logger.error 'totem_scope.get_record_path record is blank.'  unless record
    key = @record_type_key(record).underscore().replace(/\./g,'/')

  get_record_path_no_ns: (record) ->
    path = @get_record_path(record)
    @remove_namespace_from_path(path)

  remove_namespace_from_path: (path) ->
    path.split('/').get('lastObject')

  # Return either a record or a string in the ember expected format.
  standard_record_path: (path_or_record) ->
    if typeof path_or_record == 'string'
      value = path_or_record.replace(/\::/g,'/').underscore()
    else
      value = @get_record_path(path_or_record)
    value

  # Return a records's path by converting its type key to a path.
  record_has_viewed_id: (record, id, options={}) ->
    return false unless record and id
    viewed_ids = @get_viewed_record_path_ids(record, options)
    viewed_ids.contains parseInt(id)

  record_has_not_viewed_id: (record, id, options={}) -> not @record_has_viewed_id(record, id, options)

  # Helper methods to set viewed ids on a record.  This can be independent of the 'current_path' view ids used to filter records
  # and can be used to determine whether to send an ajax request to load data (or if the data is already loaded).
  # The viewed ids are stored in 'record._path_ids_[id_prop] = [ids]' to provide storing ids for different paths on the same record.
  # Options:               
  #   viewed_current_user: [TRUE|false] true (default) means the current user id has been viewed (e.g. add to viewed_ids array)
  #   id_prop:             [string] a specific property within the record's path ids to save the viewed ids (see 'get_record_path_ids_prop' for default).
  set_viewed_record_path_ids: (record, options={}) ->
    viewed_ids   = @get_viewed_record_path_ids(record, options)
    unviewed_ids = @get_unviewed_record_path_ids(record, options)
    record.set @get_record_path_ids_prop(record, options), @concat_id_arrays(viewed_ids, unviewed_ids)  # save all viewed ids on record

  get_viewed_record_path_ids: (record, options={}) ->
    viewed_ids = @make_ids_array(record.get @get_record_path_ids_prop(record, options))
    if @is_user_ids_current_path()
      viewed_ids = @concat_id_arrays(viewed_ids, @get_current_user_id())  if options.viewed_ownerable == true
    else
      if @is_blank(viewed_ids)
        viewed_ids = @concat_id_arrays(viewed_ids, @get_ownerable_id())   if options.viewed_ownerable == true
    viewed_ids

  get_unviewed_record_path_ids: (record, options={}) ->
    viewed_ids  = @get_viewed_record_path_ids(record, options)
    current_ids = @get_current_ids() or []
    current_ids.filter (id) -> not viewed_ids.contains(id)

  unviewed_record_path_ids_blank:   (record, options={}) -> @is_blank @get_unviewed_record_path_ids(record, options)
  unviewed_record_path_ids_present: (record, options={}) -> not @unviewed_record_path_ids_blank(record, options)

  get_record_path_ids_prop: (record, options={}) ->
    path_ids = '_ts_path_ids_'  # object property that the viewed ids are saved
    record.set(path_ids, {})  unless record.get(path_ids)  # first time, set as empty object
    # The path is either:
    #  1. Property specified in: options.id_prop (manually specified id property)
    #  2. Property specified in: options.sub_action (manually specified id property)
    #  3. User data 'sub' action
    #  4. Current path
    #  5. Users path (default)
    path = options.id_prop or options.sub_action or @get_sub_action() or @get_current_path() or @get_user_ids_path()
    "#{path_ids}.#{path}"

  record_ownerable_match_ownerable: (record, ownerable=null) ->
    return false unless record
    record_ownerable_type = @rails_polymorphic_type_to_path(record.get 'ownerable_type')
    record_ownerable_id   = record.get('ownerable_id')
    if ownerable
      ownerable_type = @get_record_path(ownerable)
      ownerable_id   = ownerable.get('id')
    else
      ownerable_type = @get_ownerable_type()
      ownerable_id   = @get_ownerable_id()
    record_ownerable_type == ownerable_type and parseInt(record_ownerable_id) == parseInt(ownerable_id)

  polymorphic_values_are_equal: (c1, c2) ->
    return false unless ember.isPresent(c1) and ember.isPresent(c2)
    unless c1.type? and c1.id? and c2.type? and c2.id?
      console.warn "Cannot compare polymorphic values without a type and id present in object: ", c1, c2
      return false
    c1_type = @standard_record_path(c1.type)
    c1_id   = parseInt(c1.id)
    c2_type = @standard_record_path(c2.type)
    c2_id   = parseInt(c2.id)
    ember.isEqual(c1_id, c2_id) and ember.isEqual(c1_type, c2_type)

# ###
# ### Array Helpers
# ###

totem_scope_module.reopen

  # Return array of integer ids.
  make_ids_array: (ids) ->
    ids = ember.makeArray(ids).map (id) -> parseInt(id) or null
    ids.compact()

  # Convience methods to test if the array contains any elements (e.g. empty or not empty)
  is_blank:   (ids) -> ember.isEmpty(ids)
  is_present: (ids) -> not @is_blank(ids)
  is_empty:   (ids) -> @is_blank(ids)     # alias to is_blank make backaward compatible

  # Return new concatenated id array; converts ids to integers.
  # Array params can be arrays or a string|integer (if not array, converted to an integer as a single element array)
  concat_id_arrays: (array_1, array_2) ->
    array   = []
    array_1 = @make_ids_array(array_1)
    array_2 = @make_ids_array(array_2)
    array_1.forEach (value) -> array.push value
    array_2.forEach (value) -> array.push value
    array.uniq()

# ###
# ### Authable (Polymorphic)
# ###

totem_scope_module.reopen
  # Store the authable values used by the rest adapter/serializer.
  # Typically the values would be set as record attributes instead of setting here.
  authable_type: null
  authable_id:   null

  get_authable_type: -> @get 'authable_type'
  get_authable_id:   -> @get 'authable_id'
  set_authable:      (record) -> @authable(record)

  authable: (record) -> 
    return unless record
    type = @get_record_path(record)
    id   = record.get('id')
    @set 'authable_type', type
    @set 'authable_id', id

  record_authable_match_authable: (record, authable=null) ->
    return false unless record
    record_authable_type = @rails_polymorphic_type_to_path(record.get 'authable_type')
    record_authable_id   = record.get('authable_id')
    if authable
      authable_type = @get_record_path(authable)
      authable_id   = authable.get('id')
    else
      authable_type = @get_authable_type()
      authable_id   = @get_authable_id()
    record_authable_type == authable_type and parseInt(record_authable_id) == parseInt(authable_id)

# ###
# ### Ownerable (Polymorphic)
# ###

totem_scope_module.reopen
  # Since ember-data may resolve a polymorphic to the actual record, the recommended approach is to include
  # the 'ownerable_type' and 'ownerable_id' as attributes in the serializer e.g. attributes [..., ownerable_type, ownerable_id]
  # rather than as an association (so ember-data does not resolve into the actual record).

  # Store the ownerable values used by the rest adapter/serializer.
  ownerable_type_attr: null
  ownerable_id_attr:   null
  ownerable_type:      null
  ownerable_id:        null
  ownerable_record:    null

  # Sets the ownerable AND the current_path and current_ids as the ownerable for filters.
  # e.g. use to switch filters from users to teams or vice-versa.
  ownerable: (ownerable, options={}) ->
    @set_ownerable(ownerable, options)
    @current_path_and_ids_to_ownerable()

  # Convience function to set the ownerable and current path/ids to the current_user.
  # Same as totem_scope.ownerable(null, options) but more descriptive.
  ownerable_to_current_user: (options={}) -> @ownerable @get_current_user(), options

  # Set the current path and ids to the ownerable.
  current_path_and_ids_to_ownerable: (options={}) ->
    @set_current_path_and_ids @get_ownerable_type(), @get_ownerable_id()
    @set_sub_action(options.sub_action)  if options.sub_action

  # Ownerable getters.
  get_default_ownerable_type_attr: -> 'ownerable_type'
  get_default_ownerable_id_attr:   -> 'ownerable_id'
  get_ownerable_type_attr:         -> @get('ownerable_type_attr') or @get_default_ownerable_type_attr()  # the record's attribute containing the ownerable type
  get_ownerable_id_attr:           -> @get('ownerable_id_attr')   or @get_default_ownerable_id_attr()    # the record's attribute containing the ownerable id
  get_ownerable_type:              -> @get 'ownerable_type'
  get_ownerable_id:                -> @get 'ownerable_id'
  get_ownerable_record:            -> @get('ownerable_record') or @get_current_user()

  has_ownerable:          -> @get_ownerable_type() and @get_ownerable_id()
  ownerable_is_type_user: -> @get_ownerable_type() == @get_current_user_type()

  # Set the ownerable type and ownerable id from the record (default to current user if record is null).
  # Optionally, an ownerable type and id attribute can be specified if different from 'ownerable_type' and 'ownerable_id'.
  #  * If ember-data does not resolve a polymophic into the actual record, can use 'ownerable.type' and 'ownerable.id'.
  set_ownerable: (record=null, options={}) ->
    record   ?= @get_current_user()
    type_attr = options.type_attr
    id_attr   = options.id_attr
    id_attr   = type_attr.replace('type', 'id')  if type_attr and (not id_attr)
    type      = @get_record_path(record)
    id        = record.get('id')
    @set 'ownerable_type', type
    @set 'ownerable_id', parseInt(id)
    @set 'ownerable_type_attr', type_attr
    @set 'ownerable_id_attr', id_attr
    @set 'ownerable_record', record

  # Set a record's ownerable attributes to the totem scope's ownerable type and id.
  set_record_ownerable_attributes: (record) ->
    return unless record
    type_attr = @get_ownerable_type_attr()
    id_attr   = @get_ownerable_id_attr()
    record.eachAttribute (rec_attr) =>
      switch rec_attr
        when type_attr
          record.set type_attr, @get_ownerable_type()
        when id_attr
          record.set id_attr, @get_ownerable_id()

# ###
# ### REST adapter/serializer default functions.
# ###

totem_scope_module.reopen
  # Default functions to return without modifications.
  delete_record:       -> return
  find:                -> return
  find_all:            -> return
  find_many:           -> return
  find_query:          -> return
  serialize_into_hash: -> return
  add_auth_to_query:   -> return

# # ###
# # ### REST adapter/serializer support functions.
# # ###

totem_scope_module.reopen
  # Adds authable/ownerable to query params on ajax requests.
  # The adapter/serializer override the base functions to call the related
  # function below.  A query object is always passed as an argument.

  # ### Adapter
  delete_record: (type, record, query) -> @add_auth_to_query(type, query)  # deleteRecord.
  find:          (type, id, query)     -> @add_auth_to_query(type, query)  # find with id.
  find_all:      (type, query)         -> @add_auth_to_query(type, query)  # findAll (e.g. no id).
  find_many:     (type, query)         -> @add_auth_to_query(type, query)  # findMany e.g. 'select' queries.
  find_query:    (type, query)         -> @add_auth_to_query(type, query)  # findQuery e.g. find with object instead of id.

  # ### Serializer
  # Serializer serializeIntoHash is called when serializing a record.
  # This function is called before the record is serialized so the record's ownerable attributes could be updated.
  serialize_into_hash: (hash, type, record, options) ->  @add_auth_to_query(type, hash)

  # ### Rest Helpers

  add_auth_to_query: (object, query={}) ->
    return unless object and query
    object = object.constructor  unless ember.get(object, 'isClass')
    @add_ownerable_to_query(query)  if ember.get(object, 'include_ownerable_in_query') or query.ownerable
    @add_authable_to_query(query)   if ember.get(object, 'include_authable_in_query')  or query.authable
    @add_sub_action_to_query(query)

  add_ownerable_to_query: (query, ownerable=null) ->
    query.auth ?= {}
    if ownerable or (ownerable = query.ownerable)
      ownerable_type = @get_record_path(ownerable)
      ownerable_id   = ownerable.get('id')
      delete(query.ownerable)
    else
      @ownerable_to_current_user()  unless @has_ownerable()
      ownerable_type = @get_ownerable_type()
      ownerable_id   = @get_ownerable_id()  
    query.auth.ownerable_type = ownerable_type
    query.auth.ownerable_id   = ownerable_id

  add_authable_to_query: (query, authable=null) ->
    query.auth ?= {}
    if authable or (authable = query.authable)
      authable_type = @get_record_path(authable)
      authable_id   = authable.get('id')
      delete(query.authable)
    else
      authable_type = @get_authable_type()
      authable_id   = @get_authable_id()  
    query.auth.authable_type = authable_type
    query.auth.authable_id   = authable_id

  # If sub_action in the query, override the totem_scope sub_action and remove from original query.
  add_sub_action_to_query: (query, sub_action=null) ->
    return if query.auth and query.auth.sub_action
    if sub_action or (sub_action = query.sub_action)
      query.auth ?= {}
      query.auth.sub_action = sub_action
      delete(query.sub_action)
      return
    if sub_action = @get_sub_action()
      query.auth ?= {}
      query.auth.sub_action = sub_action

  # Add the auth values to an ajax query (e.g. not a @store query).
  # Adds the sub data object if does not exist.
  add_auth_to_ajax_query: (query={}) ->
    query.data ?= {}
    query.data.authable   = query.authable   unless query.data.authable
    query.data.ownerable  = query.ownerable  unless query.data.ownerable
    query.data.sub_action = query.sub_action unless query.data.sub_action
    delete(query.authable)
    delete(query.ownerable)
    delete(query.sub_action)
    @add_authable_to_query(query.data)
    @add_ownerable_to_query(query.data)
    @add_sub_action_to_query(query.data)
    delete(query.data.authable)
    delete(query.data.ownerable)
    delete(query.data.sub_action)
    query


export default totem_scope_module.create()  # Create the object to be registered/injected.
