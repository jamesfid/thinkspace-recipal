import ember          from 'ember'
import ns             from 'totem/ns'
import config         from 'totem/config'
import base_component from 'thinkspace-base/components/base'
import tc             from 'totem/cache'
import totem_scope    from 'totem/scope'

export default base_component.extend
  # ### Services
  thinkspace: ember.inject.service()

  # ### Properties
  tagName: ''
  tos:     null # Terms of service, Agreement

  # ### Computed properties
  tos_link: ember.computed.reads 'tos.link'

  update_user_terms_date: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        action: 'update_tos'
        model:  totem_scope.get_current_user()
        verb:   'PUT'
        id:     totem_scope.get_current_user_id()

      tc.query(ns.to_p('user'), query, {single: true}).then =>
        resolve()

  transition_to_target: ->
    thinkspace = @get('thinkspace')
    target     = thinkspace.get_current_transition()

    if thinkspace.transition_is_for(target, 'terms')
      @transitionToRoute(ns.to_p 'spaces')
    else
      target.retry()

  actions:
    deny:   -> @transitionToRoute('/users/sign_in')
    accept: -> @update_user_terms_date().then => @transition_to_target()
