import ember from 'ember'
import auth_config from 'simple-auth/configuration'
import base       from 'thinkspace-base/base/route'

export default base.extend
  model: (params) -> params

  actions:
    sign_in_transition: ->
      sign_in_url = auth_config.authenticationRoute
      @transitionTo sign_in_url  if sign_in_url