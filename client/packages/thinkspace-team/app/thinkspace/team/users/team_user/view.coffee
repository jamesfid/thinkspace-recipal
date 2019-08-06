import ember from 'ember'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:      'li'
  classNames:   ['team_users-team-list-user']

  actions:
    remove_user: -> @get('controller').delete_team_user(@get('team'), @get('user'))
