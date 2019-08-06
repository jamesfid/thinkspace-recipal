import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base  from 'thinkspace-casespace/components/ownerable/bar/base'

export default base.extend
  # ### Services
  casespace_peer_review: ember.inject.service()
  
  # ### Properties

  # ### Computed properties
  ownerables: ember.computed 'model', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      return resolve([]) unless ember.isPresent(model)
      if model.is_team_ownerable()
        @get('casespace_peer_review').get_peer_review_teams(model).then (teams) =>
          resolve(teams)
      else
        @get('casespace_peer_review').get_peer_review_users(model).then (users) =>
          resolve(users)
    ta.PromiseArray.create promise: promise