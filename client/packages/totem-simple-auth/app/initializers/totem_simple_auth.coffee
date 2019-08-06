import ember                     from 'ember'
import authenticator             from 'totem-simple-auth/authenticator'
import authorizer                from 'totem-simple-auth/authorizer'
import authenticator_switch_user from 'totem-simple-auth/authenticator_switch_user'
import cookie_store              from 'totem-simple-auth/cookie_store'

initializer = 
  name:   'totem-simple-auth'
  after:  ['totem','simple-auth-devise']  # must be after  'simple-auth-devise' or authorize function won't be called
  before: ['simple-auth']         # must be before 'simple-auth' or restore function won't be called

  initialize: (container, app) ->
    container.register('authenticator:totem', authenticator)
    container.register('authenticator_switch_user:totem', authenticator_switch_user)
    container.register('authorizer:totem', authorizer)
    container.register('simple-auth-session-store:totem-cookie-store', cookie_store)

export default initializer
