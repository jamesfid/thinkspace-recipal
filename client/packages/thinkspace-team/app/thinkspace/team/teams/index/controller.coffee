import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-team/controllers/base'

export default base.extend

  actions:
    filter_by_collaboration_teams: -> @set_team_filter_category @get('collaboration_category')
    filter_by_peer_review_teams:   -> @set_team_filter_category @get('peer_review_category')
    filter_teams_off:              -> @set_team_filter_category()