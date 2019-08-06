import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace/components/dock_base'

export default base.extend

  casespace_peer_review: ember.inject.service()

  addon_name:         'peer_review'
  addon_display_name: 'Peer Review'

  c_phase: ns.to_p 'peer_review', 'phase'

  can_peer_review_users: ember.computed.bool 'current_phase.can.peer_review_users'
  can_peer_review_teams: ember.computed.bool 'current_phase.can.peer_review_teams'
  can_peer_review:       ember.computed.or   'can_peer_review_users', 'can_peer_review_teams'
  can_access_addon:      ember.computed.and  'has_phase_view', 'can_peer_review'

  exit_addon: -> @get('casespace_peer_review').clear()

  actions:
    exit: ->
      # Override the base's exit action to reset the team if the current phase has a team ownerable.
      # Note: If reset the ownerable as the current_user, the phase view generation will error attempting
      #       to get component data for the current user rather than a team since is a view generation
      #       and not a transitionTo.
      phase = @get('current_phase')
      if phase.is_team_ownerable()
        map       = @get('casespace_peer_review')
        ownerable = map.get_team_ownerable()
        @exit_addon_common()
        @set_ownerable(ownerable)
        @generate_phase_view()
      else
        @_super()

  valid_addon_ownerable: (addon_ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(true) if @get('can_peer_review')
      @validate_ownerable(addon_ownerable).then (valid) =>
        @exit_addon_common() unless valid
        resolve(valid)

  validate_ownerable: (ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      map   = @get('casespace_peer_review')
      phase = @get('current_phase')
      if @get('can_peer_review')
        if phase.is_team_ownerable()
          map.get_peer_review_teams(phase).then (teams) =>
            resolve teams.contains(ownerable)
        else
          map.get_peer_review_users(phase).then (users) =>
            resolve users.contains(ownerable)
      else
        resolve(false)
