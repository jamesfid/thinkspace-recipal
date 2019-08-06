import ember from 'ember'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:           'li'
  classNames:        ['team_viewers-team-viewer-list-user']

  is_team_assigned: ember.computed "controller.selected_team.#{ns.to_prop('team_viewers', '@each')}", ->
    @get('controller').is_viewer_assigned(@get('controller.selected_team'), @get('team'))

  actions:
    add_team:    -> @get('controller').create_team_viewer(@get('controller.selected_team'), @get('team'))
    remove_team: -> @get('controller').delete_team_viewer(@get('controller.selected_team'), @get('team'))
