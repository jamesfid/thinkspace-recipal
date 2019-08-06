import ember from 'ember'
import totem_scope from 'totem/scope'
import config      from 'totem/config'
export default ember.Controller.extend
  queryParams: ['token', 'email', 'invitable']

  token: null
  invitable: null

  invitation_present: ember.computed.notEmpty 'token'
  provided_token: ember.computed.reads 'token'
  provided_invitable: ember.computed.reads 'invitable'

  c_user_sign_up: ember.computed -> config.simple_auth.sign_up_template || 'thinkspace/common/user/new'

  actions:

    sign_in_transition: (invitable, email) ->
      @transitionToRoute 'users.sign_in', {queryParams: {invitable: invitable, email: email, refer: 'signup'}}