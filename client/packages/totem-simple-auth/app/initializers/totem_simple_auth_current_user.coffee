import ember          from 'ember'
import ns             from 'totem/ns'
import session        from 'simple-auth/session'
import totem_messages from 'totem-messages/messages'

initializer = 
  name:       'totem-simple-auth-current-user'
  before:      ['simple-auth']    # must be before 'simple-auth' or restore function won't be called

  initialize: (container, app) ->
    session.reopen
      totem_scope:      ember.inject.service()
      user:             ember.computed.reads 'totem_scope.current_user'
      is_original_user: ember.computed.bool  'secure.original_user'
      can_switch_user:  ember.computed.bool  'secure.switch_user'

export default initializer
