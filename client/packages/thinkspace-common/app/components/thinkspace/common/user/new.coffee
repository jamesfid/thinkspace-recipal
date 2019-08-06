import ember      from 'ember'
import ns         from 'totem/ns'
import ajax       from 'totem/ajax'
import val_mixin  from 'totem/mixins/validations'
import util       from 'totem/util'
import base_component from 'thinkspace-base/components/base'
import sign_up_terms from 'thinkspace-common/mixins/sign_up_terms'

export default base_component.extend val_mixin, sign_up_terms,
  # ### Properties
  tagName:       ''
  first_name:     null
  last_name:      null
  user_email:     null
  password:       null

  fields:              ['first_name', 'last_name', 'email', 'password']
  taken_emails:        []
  email_taken_message: 'Email has already been taken'

  is_instructor: false
  is_student:    true

  # ### Invitation properties
  invitation_present: false
  invitation_invalid: ember.computed.notEmpty 'invitation_status'
  invitation_status:  null
  invitation_accepted: false
  attempts:           0

  # ### Computed properties
  initial_validate_first_name: ember.computed.gt 'attempts', 0
  initial_validate_last_name: ember.computed.gt 'attempts', 0
  initial_validate_email: ember.computed 'attempts', 'email', ->
    return true if @get('email')
    return @get('attempts') > 0
  initial_validate_password: ember.computed.gt 'attempts', 0

  email:          ember.computed.reads 'user_email'
  email_provided: ember.computed.notEmpty 'user_email'
  lock_email:     ember.computed.or 'authenticating', 'email_provided'

  # ### Components
  c_radio:           ns.to_p 'common', 'shared', 'radio'
  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_loader:          ns.to_p 'common', 'shared', 'loader'
  c_pwd_meter:       ns.to_p 'common', 'user', 'password', 'meter'

  # ### Observer
  # custom handling since its not going through ember validations
  set_email_taken_errors: ember.observer 'email', ->
    email               = @get('email')
    taken_emails        = @get('taken_emails')
    email_errors        = @get('errors.email')
    email_taken_message = @get('email_taken_message')
    if taken_emails.contains(email)
      email_errors.pushObject(email_taken_message) unless email.contains(email_taken_message)
    else if email_errors.contains(email_taken_message) and not (taken_emails.contains(email))
      email_errors.removeObject(email_taken_message)

  didInsertElement: ->
    @set_focus_first_input()
    @get_latest_terms().then (tos) =>
      @set('tos', tos) if ember.isPresent(tos)

      if ember.isPresent @get('token')
        @get_invitation_state().then (result) =>
          @set 'invitation_accepted', true if result.state and (result.state == 'accepted' or result.state == 'autoaccepted')

  get_invitation_state: ->
    token = @get('token')
    options =
      verb:   'GET'
      action: 'fetch_state'
      model:  'thinkspace/common/invitation'
      id:     token

    ajax.object(options)

  validate_and_set_focus: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate().then (valid) =>
        @set_focus_on_error()
        resolve(false) if @has_validation_error() # not valid if there is an error to focus on
        resolve(@get('isValid'))
      , (error) =>
        @set_focus_on_error()
        resolve(@get('isValid'))

  has_validation_error: ->
    errors = @get('errors')
    fields = @get('fields')
    for field in fields
      return true unless ember.isEmpty(errors[field])
    return false

  set_focus_on_error: ->
    ember.run.schedule 'afterRender', =>
      errors = @get('errors')
      fields = @get('fields')
      for field in fields
        unless ember.isEmpty(errors[field])
          $input = $("form input[name='#{field}']")
          $input.select()
          return true
      return false

  set_focus_first_input: ->
    $('form input').first().select()

  # hacky way to find out what type (invitation problem, user validation, oauth down, etc.) of error it is
  handle_api_error: (errors) ->
    if util.starts_with(errors.user_message, 'Email')
      @get('errors.email').pushObject(errors.user_message) unless @get('errors.email').contains(errors.user_message)
      @get('taken_emails').pushObject(@get('email')) unless @get('taken_emails').contains(@get('email'))
      @validate_and_set_focus()
    else if util.starts_with(errors.user_message, 'Invitation')
      @set 'invitation_status', errors.user_message
    else
      @set 'api_response_status', errors.user_message

  get_profile: ->
    is_instructor = @get 'is_instructor'
    is_student    = @get 'is_student'
    profile =
      roles:
        student:    is_student
        instructor: is_instructor

  actions:
    submit: ->
      @incrementProperty 'attempts'
      @validate_and_set_focus().then (valid) =>
        return unless valid
        @set 'authenticating', true
        query =
          url:  '/api/thinkspace/common/users'
          verb: 'POST'
          data:
            'thinkspace/common/user':
              first_name:    @get('first_name')
              last_name:     @get('last_name')
              email:         @get('email')
              password:      @get('password')
              token:         @get('token')
              profile:       @get_profile()


        ajax.object(query).then (payload) =>
          @set 'authenticating', false
          @sendAction 'sign_in_transition', @get('invitable'), @get('email')
        , (error) =>
          @set 'authenticating', false
          @handle_api_error(error.responseJSON.errors)

    toggle_persist_login: (checked) ->
      @set 'persist_login', checked
      false

    set_is_instructor: -> @set('is_instructor', true); @set('is_student', false)
    set_is_student:    -> @set('is_student', true); @set('is_instructor', false)

  validations:
    first_name:
      presence: {message: "First name can't be blank"}
    last_name:
      presence: {message: "Last name can't be blank"}
    email:
      format: {with: /\S+@\S+/, message: "Must be a valid email"}
    password:
      length: {minimum: 8, messages: {tooShort: "Password needs to be at least 8 characters long"}}
      password_strength: {}
