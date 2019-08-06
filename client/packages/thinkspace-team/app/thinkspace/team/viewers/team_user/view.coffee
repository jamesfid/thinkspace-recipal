import ember from 'ember'
import ns    from 'totem/ns'

export default ember.View.extend

  tagName:      'li'
  classNames:   ['team_viewers-team-list-user']

  actions:
    remove_user: -> @get('controller').delete_team_viewer(@get('review_team'), @get('viewer_user'))
