import ember from 'ember'
import util  from 'totem/util'
import reqm  from 'totem/config/require_modules'

class TotemRoutes

  constructor: ->
    @root_routes   = {}
    @nested_routes = {}
    @path_to_map   = {}
    @ember_routes  = []
    @map_options   = {}
    @populate_routes()

  populate_routes: ->
    regex = reqm.config_regex('routes')
    mods  = reqm.filter_by(regex)
    return if ember.isBlank(mods)
    for mod in mods
      hash = reqm.require_module(mod)
      @error "Module '#{mod}' is not a hash."  unless reqm.is_hash(hash)
      for name, options of hash
        if @is_root_route(name)
          @root_route(mod, name, options)
        else
          @nested_route(mod, name, options)  # name is the parent route in nested routes (e.g. starts with a '/')

  is_root_route:   (name) -> not @is_nested_route(name)
  is_nested_route: (name) -> util.starts_with(name, '/')

  # ###
  # ### Store Routes from Package.
  # ###

  root_route: (mod, name, options={}) ->
    @standardize_route_options(mod, name, options)
    path = options.path
    @validate_route_path(@root_routes, path, options)
    @validate_route_name(@root_routes, name, options)
    @root_routes[path] = options

  nested_route: (mod, parent, options={}) ->
    for own name, opts of options
      opts ?= {}
      @standardize_route_options(mod, name, opts, parent)
      path          = opts.path
      parent_routes = @nested_routes[parent] ?= {}
      @validate_route_name(parent_routes, name, opts)
      @validate_route_path(parent_routes, path, opts)
      parent_routes[path] = opts

  standardize_route_options: (mod, name, options, parent=null) ->
    @error "Route options for '#{name}' is not a hash."  unless reqm.is_hash(options)
    options.path  ?= ('/' + name)
    options.name   = name
    options.mod    = mod
    options.parent = parent

  get_routes_path_module_name: (routes, path) -> (routes[path] or {}).mod or 'unknown'

  # ###
  # ### Route Validations.
  # ###

  validate_route_path: (routes, path, options) ->
    if routes[path]
      type     = @get_route_name_type(options)
      mod      = options.mod
      name     = options.name
      dup_opts = routes[path]
      dup_mod  = dup_opts.mod
      dup_name = dup_opts.name
      message  = "Duplicate #{type} route PATH '#{path}'.\nModule: #{mod}\n  name: #{name}\nModule: #{dup_mod}\n  name: #{dup_name}"
      @error(message)

  validate_route_name: (routes, name, options) ->
    for dup_path, dup_opts of routes
      if name == dup_opts.name
        type     = @get_route_name_type(options)
        mod      = options.mod
        path     = @get_options_path(options)
        dup_mod  = dup_opts.mod
        dup_path = @get_options_path(dup_opts)
        message  = "Duplicate #{type} route NAME '#{name}'.\nModule: #{mod}\n  path: '#{path}'\nModule: #{dup_mod}\n  path: '#{dup_path}'"
        @error(message)

  get_options_path: (options) ->
    path   = options.path
    parent = options.parent
    (parent and (parent + path)) or path

  get_route_name_type: (options) -> (options and options.parent and 'nested') or 'root'

  # ###
  # ### Main Function called by Router.
  # ###

  # ### Map does not return any value but generates the routes based
  # ### on the initial 'rmap' argument e.g. Router.map -> tr.map(@).
  map: (rmap) ->
    @map_roots(rmap)
    @map_nests()
    @print_routes()  if @map_options.print_routes
    @reset_temporary_map_values()

  reset_temporary_map_values: ->
    @path_to_map  = {}
    @ember_routes = []

  map_roots: (rmap) ->
    @map_root(rmap, path, options) for path, options of @root_routes

  map_root: (rmap, path, options) ->
    key   = path
    name  = options.name
    @remove_non_ember_options(options)
    _this = @
    rmap.resource name, options, ->
      _this.path_to_map[key] = @
      _this.ember_routes.push(@matches)  if _this.map_options.print_routes

  map_nests: ->
    @map_nest(parent, paths) for parent, paths of @nested_routes

  map_nest: (parent, paths) ->
    rmap   = @get_nested_path_map(parent)
    routes = @ember_routes
    _this  = @
    for own path, options of paths
      name = options.name
      fn   = (options.resource and 'resource') or 'route'
      @remove_non_ember_options(options)
      rmap[fn] name, options, ->
        key = parent + path
        _this.path_to_map[key] = @
        _this.ember_routes.push(@matches)  if _this.map_options.print_routes

  get_nested_path_map: (parent) ->
    rmap = @path_to_map[parent]
    return rmap if ember.isPresent(rmap)
    similar = []
    for own path, options of @path_to_map
      similar.push(path)  if path.match(parent)
      similar.push(path)  if parent.match(path)
    similar = similar.sort()
    @print()
    message = ''
    message = "  Did you mean one of these?\n[#{similar.join('], [')}]"  if ember.isPresent(similar)
    @error "No parent-path route map matches [#{parent}]." + message

  remove_non_ember_options: (options) ->
    # Ember appears to ignore them, but deleting just in case.
    delete(options.mod)
    delete(options.name)
    delete(options.parent)
    delete(options.resource)

  # ###
  # ### Print Routes.
  # ###

  # TODO: get from totem config?
  print_routes_on:  -> @map_options.print_routes = true
  print_routes_off: -> @map_options.print_routes = false

  print_routes: ->
    output = []
    routes = util.flatten_array(@ember_routes).compact().filter (r) -> typeof(r) == 'string'
    routes = routes.uniq().filter (r) -> not (util.starts_with r, '/_unused_dummy')
    routes = routes.filter (r) -> not (util.starts_with(r, '/') and r != '/')
    count  = 0
    for route in routes.sort()
      count += 1
      c      = util.rjust(count, 4)
      output.push "#{c}. #{route}"
    console.info output.join "\n"

  print: ->
    console.warn 'root_routes:',   @root_routes
    console.warn 'nested_routes:', @nested_routes

  # ###
  # ### Helpers.
  # ###

  stringify: (obj) -> JSON.stringify(obj)

  error: (message='') -> reqm.error(@, message)

  toString: -> 'TotemRoutes'

export default new TotemRoutes
