import ember    from 'ember'
import dock_map from 'thinkspace-dock/map'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName:      ''
  route_change: ember.observer 'current_route', -> @set_dock_addons()
  addons:       []

  init: ->
    @_super()
    @set_dock_addons()

  set_dock_addons: ->
    route           = @get('current_route')
    required_addons = dock_map.get_required_addons(route) or []
    route_addons    = dock_map.get_route_addons(route) or []
    @set 'addons', @group_addons(required_addons, route_addons)

  ## Orders addons based on keys 'group' and 'order'. Group responds to 'first', 'last', and 'middle'.
  ## => Group will place the addon into an array, while order will try to determine the addon's place in that array.
  ## => If an order is specified that is outside the bounds of the array, will place as close as possible.
  group_addons: (required_addons, route_addons) ->
    all_addons = required_addons.concat(route_addons)
    first      = []
    middle     = []
    last       = []
    for addon in all_addons
      if addon.group?
        if addon.group == 'first'
          first.pushObject(addon)
        else if addon.group == 'middle'
          middle.pushObject(addon)
        else if addon.group == 'last'
          last.pushObject(addon)
      else
        middle.pushObject(addon)
    first.concat(middle.concat(last))
