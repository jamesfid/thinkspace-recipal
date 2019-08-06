import ember from 'ember'
import auth_config from 'simple-auth/configuration'

export default ember.Route.extend

  redirect: ->
    sign_in_url = auth_config.authenticationRoute
    @transitionTo sign_in_url  if sign_in_url
