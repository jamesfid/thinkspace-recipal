import ember from 'ember'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:           'li'
  classNames:        ['team_viewers-user-viewer-list-user']

  is_user_assigned: ember.computed "controller.selected_team.#{ns.to_prop('team_viewers', '@each')}", ->
    @get('controller').is_viewer_assigned(@get('controller.selected_team'), @get('user'))

  actions:
    add_user:    -> @get('controller').create_team_viewer(@get('controller.selected_team'), @get('user'))
    remove_user: -> @get('controller').delete_team_viewer(@get('controller.selected_team'), @get('user'))
