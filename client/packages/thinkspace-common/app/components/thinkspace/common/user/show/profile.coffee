import ember          from 'ember'
import ns             from 'totem/ns'
import val_mixin      from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'
import util           from 'totem/util'

export default base_component.extend val_mixin,
  model: null

  # Components
  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_file_upload:     ns.to_p 'common', 'file-upload'
  c_radio:           ns.to_p 'common', 'shared', 'radio'
  c_dropdown:        ns.to_p 'common', 'dropdown'

  # Partials
  p_header: 'components/' + ns.to_p('user', 'show', 'header')

  # Computed Properties
  first_name:      ember.computed.reads 'model.first_name'
  last_name:       ember.computed.reads 'model.last_name'
  email:           ember.computed.reads 'model.email'
  email_optin:     ember.computed.reads 'model.email_optin'
  avatar_url:      ember.computed.reads 'model.avatar_url'
  instructor_role: ember.computed.reads 'model.profile.roles.instructor'
  student_role:    ember.computed.reads 'model.profile.roles.student'

  update_password: null

  is_instructor:   ember.computed.reads 'instructor_role'
  is_student:      ember.computed.reads 'student_role'

  # Routes
  r_user_profile: 'users.show.profile'
  r_user_keys:    'users.show.keys'

  upload_avatar_form_action:  ember.computed 'model', -> "/api/thinkspace/common/users/#{@get('model.id')}/avatar"
  upload_avatar_model_path:   'thinkspace/common/user'
  upload_avatar_params:       ember.computed 'model', -> {id: @get('model.id')}
  upload_avatar_btn_text:     'Upload New Picture'
  upload_avatar_loading_text: 'Uploading picture..'
  upload_avatar_select_text:  'Select File'

  init: ->
    @_super()

    @load_domain_data().then =>
      @set_data()

  load_domain_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('discipline')).then (disciplines) =>
        @set('all_disciplines', disciplines)
        resolve()

  set_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get(ns.to_p('disciplines')).then (model_disciplines) =>
        @set('discipline', model_disciplines.get('firstObject'))
        resolve()

  save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate().then =>
        @sync_save().then (synced_model) =>
          @totem_messages.show_loading_outlet()
          synced_model.save().then =>
            @totem_messages.hide_loading_outlet()
            resolve()
          .catch =>
            @totem_messages.hide_loading_outlet()
            reject()
      .catch =>
        @totem_messages.error('Please ensure that your name is present.')
        reject()

  sync_save: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model       = @get('model')

      first_name        = @get('first_name')
      last_name         = @get('last_name')
      email_optin       = @get('email_optin')
      discipline        = @get('discipline')

      @sync_discipline()
      @sync_role('instructor')
      @sync_role('student')

      model.set('first_name',  first_name)
      model.set('last_name',   last_name)
      model.set('email_optin', email_optin)

      resolve(model)

  sync_discipline: ->
    model = @get('model')
    discipline = @get('discipline')

    if ember.isPresent(discipline)
      update             = {}
      update.disciplines = []
      update.disciplines.pushObject(parseInt(discipline.get('id')))
      model.set('updates', update)

  sync_role: (role) ->
    value = @get("is_#{role}")
    model = @get('model')

    unless ember.isPresent(value)
      value = false

    util.set_path_value(model, "profile.roles.#{role}", value)

  actions:
    select_discipline: (discipline) -> @set('discipline', discipline)

    set_role: (role) ->
      switch role
        when 'instructor'
          @set('is_instructor', true)
          @set('is_student',    false)
        when 'student'
          @set('is_instructor', false)
          @set('is_student',    true)

    update_password: -> @sendAction 'update_password'

    update_information: ->
      model = @get('model')

      @save().then =>
        @totem_messages.api_success source: @, model: model, action: 'update', i18n_path: ns.to_o('user', 'update_success')
      .catch =>
        @totem_messages.api_failure source: @, model: model, action: 'update', i18n_path: ns.to_o('user', 'update_failure')

  validations:
    first_name:
      presence:
        message: 'Please fill out your first name.'
    last_name:
      presence:
        message: 'Please fill out your last name.'
