import ember       from 'ember'
import totem_scope from 'totem/scope'
import config      from 'totem/config'
import auth_mixin  from 'simple-auth/mixins/authenticated-route-mixin'

export default ember.Route.extend auth_mixin,
  thinkspace: ember.inject.service()

  beforeModel: (transition) ->
    @_super(transition)

    # user        = totem_scope.get_current_user()
    # tos_current = user.get('tos_current')

    # if ember.isNone(tos_current) or tos_current == false
    #   thinkspace = @get('thinkspace')
    #   thinkspace.set_current_transition(transition)
    #   @transitionTo('users.terms', user)