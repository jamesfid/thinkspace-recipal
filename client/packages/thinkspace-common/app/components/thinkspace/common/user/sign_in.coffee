import ember          from 'ember'
import ns             from 'totem/ns'
import ajax           from 'totem/ajax'
import val_mixin      from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'
import sign_up_terms  from 'thinkspace-common/mixins/sign_up_terms'

export default base_component.extend val_mixin, sign_up_terms,
  tagName:       ''

  user_email: null
  password:   null
  invitable:  null
  refer:      null

  email: ember.computed.reads 'user_email'

  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_loader:          ns.to_p 'common', 'shared', 'loader'

  authenticator:             'authenticator:totem'
  credentials_error_message: 'Email or password incorrect'

  invitation_present:   ember.computed.notEmpty 'invitable'
  referred_from_signup: ember.computed.equal 'refer', 'signup'
  has_errors:           ember.computed.reads 'totem_messages.error_present'
  error_messages:       ember.computed.reads 'totem_messages.message_queue'

  didInsertElement: ->
    @set_focus_first_input()
    @get_latest_terms().then (tos) =>
      @set('tos', tos) if ember.isPresent(tos)

  set_focus_first_input: ->
    $('form input').first().select()

  set_user_credentials_error: ->
    errors                    = @get('errors')
    credentials_error_message = @get('credentials_error_message')
    errors.email.pushObject(credentials_error_message) unless errors.email.contains(credentials_error_message)

  reset_user_credentials_error: ember.observer 'email', ->
    errors                    = @get('errors')
    credentials_error_message = @get('credentials_error_message')
    errors.email.removeObject(credentials_error_message) if errors.email.contains(credentials_error_message)

  actions:

    submit: ->
      @set 'authenticating', true
      data = {identification: @get('email'), password: @get('password')}
      @set 'password', null
      @get('session').authenticate(@get('authenticator'), data).then =>
        @set 'authenticating', false
        @totem_messages.info "Sign in successful!"
      , (error) =>
        @set 'authenticating', false
        @set_user_credentials_error()
        message = error.responseText or 'Invalid credentials.'
        @totem_messages.error message
