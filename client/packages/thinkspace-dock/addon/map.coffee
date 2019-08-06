import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'

export default ember.Object.create

  show_map:   ember.Object.create()
  except_map: ember.Object.create()

  required_addons: null

  show: (route, addons) ->
    addons = ember.makeArray(addons)
    map    = @get('show_map')
    util.add_path_objects(map, route)
    map_addons = @get_map_addons(map, route)
    if ember.isArray(map_addons)
      for addon in addons
        map_addons.push(addon) unless @addon_included(map_addons, addon)
    else
      map.set route, _doc_addons: addons

  except: (route) ->
    map = @get('except_map')
    util.add_path_objects(map, route)
    map.set route, true

  get_required_addons: (route) -> @get('required_addons')

  set_required_addons: (addons) ->
    addons          = ember.makeArray(addons)
    required_addons = @get 'required_addons'
    if ember.isArray(required_addons)
      for addon in addons
        required_addons.push(addon) unless @addon_included(required_addons, addon)
    else
      @set 'required_addons', addons

  get_route_addons: (route) ->
    return [] unless route
    return [] if @is_except_route(route)
    map    = @get('show_map')
    addons = @get_map_addons(map, route)  # full route addons match e.g. my/route.show
    unless ember.isArray(addons)
      route_match = route.replace(/\..*$/,'.*')      # replace route action with wildcard e.g. '.show' -> '.*'
      addons      = @get_map_addons(map, route_match) # wildcard route addons
    addons or []

  is_except_route: (route) ->
    map = @get('except_map')
    return false unless map
    return true  if map.get(route) == true  # has exception for full route
    for own key, value of map
      unless typeof(value) == 'function'
        if except = map.get("#{key}.*")
          [path, last] = @get_path_route(route)
          if path and util.starts_with(route, path)
            return true if except == true        # paths starting with this path are exceptions
            return true if except[last] == true  # paths starting with this path for this route are exceptions
    false

  addon_included: (addons, addon) -> addons.findBy 'path', addon.path

  get_map_addons: (map, route) -> map.get(route + '._doc_addons')

  get_path_route: (route_name) ->
    parts = route_name.split('.')
    route = parts.pop()
    path  = parts.join('.')
    [path, route]
