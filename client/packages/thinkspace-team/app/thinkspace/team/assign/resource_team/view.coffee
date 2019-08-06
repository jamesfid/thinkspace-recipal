import ember from 'ember'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:      'li'
  classNames:   ['team_assign-resource-list-team']

  actions:
    remove_team: -> @get('controller').delete_team_teamable(@get('team'), @get('resource'))
