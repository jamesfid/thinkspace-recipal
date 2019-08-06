import ember  from 'ember'

export default ember.Controller.extend

  authenticator: 'authenticator:totem'

  has_errors:     ember.computed.reads 'totem_messages.error_present'
  error_messages: ember.computed.reads 'totem_messages.message_queue'

  actions:

    authenticate: ->
      data = @getProperties('identification', 'password')
      @set 'password', null
      @get('session').authenticate(@get('authenticator'), data).then =>
        @totem_messages.info "#{data.identification} sign in successful."
      , (error) =>
        message = error.responseText or 'Invalid credentials.'
        @totem_messages.error message

