import ember from 'ember'
import util  from 'totem/util'
import reqm  from 'totem/config/require_modules'

class TotemNamespaceMap

  constructor: ->
    @ns_map = {
      namespaces:        {}
      type_to_namespace: {}
    }
    @populate_ns_map()

  to_p:    -> @type_to(arguments, '/')
  to_r:    -> @type_to(arguments, '.', '/')
  to_prop: -> @type_to(arguments, '.', '/', false)
  to_t:    -> 'components/' + @to_p(arguments)
  to_c:    -> 'components/' + @to_p(arguments)
  to_m:    -> 'mixins/'     + @to_p(arguments)
  to_o:    -> @to_p(arguments).replace(/\//g, '.') # to object notation, e.g. 'thinkspace.input_element.response'

  type_to: (args, sep, type_sep=null, underscore_parts=true) ->
    parts = util.flatten_array(args)
    type  = parts.shift()
    @error "type was not passed as an argument."  unless type?
    type  = type.underscore()

    if underscore_parts
      parts = parts.map (part) -> part.underscore()

    stype = type.singularize()
    ns    = @ns_map.type_to_namespace[stype]
    if ns?
      # If type is a type-to-namespace, set the path to the type's namespace path.
      # The type will be added to the path.
      path = @ns_map.namespaces[ns]
      @error "namespace for [#{ns}] not defined for type [#{stype}]."  unless path?
    else
      # If not a type-to-namespace, check whether the type 'is' a namespace.
      # If it is, set the path to the namespace path and set the type to be ignored.
      path = @ns_map.namespaces[stype] or @ns_map.namespaces[type]  # try singular then plural
      @error "type_to_namespace [#{stype}] not defined." unless path?
      type = null
  
    # Allow a type value to be namespaced where the type itself may be a duplicate e.g. 'parent'.
    # The type value is split by ':' and the type becomes the value 'after' the ':'
    # (the first part is ignored since only used to make the type key unique in the map).
    # An association name should be formatted like: 'model-name:association-name'
    if type?
      type = type.split(':', 2).pop()  if type.match(':')
      (type_sep and path += type_sep + type) or (path += sep + type)

    if parts.length > 0
      if type_sep
        last = parts.pop()
        path += type_sep + parts.join(type_sep)  if parts.length > 0
        path += sep + last
      else
        path += sep + parts.join(sep)

    path

  # ###
  # ### Populate.
  # ###

  populate_ns_map: ->
    regex = reqm.config_regex('ns')
    mods  = reqm.filter_by(regex)
    return if ember.isBlank(mods)
    for mod in mods
      map = reqm.require_module(mod)
      @error "Module '#{mod}' is not a hash."  unless reqm.is_hash(map)
      namespaces = map.namespaces or {}
      @error "Module '#{mod}' key 'namespaces' is not a hash."  unless reqm.is_hash(namespaces)
      for ns, val of namespaces
        @error "Module '#{mod}' namespace is not a string."        unless reqm.is_string(ns)
        @error "Module '#{mod}' namespace value is not a string."  unless reqm.is_string(val)
        @error "Module '#{mod}' namespaces '#{ns}' is a duplicate."  if ember.isPresent(@ns_map.namespaces[ns])
        @ns_map.namespaces[ns] = val
      type_to_namespace = map.type_to_namespace or {}
      @error "Module '#{mod}' key 'type_to_namespace' is not a hash."  unless reqm.is_hash(type_to_namespace)
      for type, ns of type_to_namespace
        @error "Module '#{mod}' type_to_namespace type is not a string."       unless reqm.is_string(type)
        @error "Module '#{mod}' type_to_namespace namespace is not a string."  unless reqm.is_string(ns)
        @error "Module '#{mod}' type_to_namespace '#{type}' is a duplicate."  if ember.isPresent(@ns_map.type_to_namespace[type])
        @ns_map.type_to_namespace[type] = ns
    @validate_integrity()

  validate_integrity: ->
    for type, ns of @ns_map.type_to_namespace
      @error "Namespace '#{ns}' for type '#{type}' does not exist."  if ember.isBlank(@ns_map.namespaces[ns])

  # ###
  # ### Helpers.
  # ###

  error: (message='') -> reqm.error(@, message)

  toString: -> 'TotemNamespaceMap'

export default new TotemNamespaceMap
