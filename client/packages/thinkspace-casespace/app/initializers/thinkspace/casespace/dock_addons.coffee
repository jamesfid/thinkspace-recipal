import ember    from 'ember'
import ns       from 'totem/ns'
import dock_map from 'thinkspace-dock/map'

initializer = 
  name:  'thinkspace-casespace-dock-addons'
  after: ['totem']

  initialize: (container, app) ->
    peer_review  = {path: ns.to_p('peer_review',  'dock'),     group: 'first'}
    gradebook    = {path: ns.to_p('gradebook',    'dock'),     group: 'first'}
    case_manager = {path: ns.to_p('case_manager', 'dock'),     group: 'first'}
    resources    = {path: ns.to_p('resource',    'dock'),      group: 'middle'}
    comments     = {path: ns.to_p('markup', 'dock'),           group: 'middle'}

    dock_map.show ns.to_r('assignments', 'show.index'), [resources]
    dock_map.show ns.to_r('phases', 'show.index'),      [resources]

    # ### TODO: Re-add when possible.
    #dock_map.show ns.to_r('assignments', 'show.index'), [gradebook]
    dock_map.show ns.to_r('phases', 'show.index'),      [gradebook]

    dock_map.show ns.to_r('assignments', 'show.index'), [peer_review]
    dock_map.show ns.to_r('phases', 'show.index'),      [peer_review]

    dock_map.show ns.to_r('phases', 'show.index'), [comments]

export default initializer
