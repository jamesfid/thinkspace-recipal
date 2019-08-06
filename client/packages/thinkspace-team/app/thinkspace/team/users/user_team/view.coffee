import ember from 'ember'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:      'li'
  classNames:   ['team_users-user-list-team']

  actions:
    remove_team: -> @get('controller').delete_team_user(@get('team'), @get('user'))
