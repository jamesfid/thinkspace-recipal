import ember          from 'ember'
import ns             from 'totem/ns'
import val_mixin      from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'
import util           from 'totem/util'

export default base_component.extend val_mixin,
  model: null

  # Partials
  p_header:  'components/' + ns.to_p('user', 'show', 'header')
  p_add_key: 'components/' + ns.to_p('user', 'show', 'add_key')

  # Components
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_loader:          ns.to_p 'common', 'loader'

  # Computed Properties
  has_key:         ember.computed.reads 'model.has_key'

  # Routes
  r_user_profile: 'users.show.profile'
  r_user_keys:    'users.show.keys'

  # Properties
  key: null

  init: ->
    @_super()
    @init_keys().then =>
      @set_all_data_loaded()

  init_keys: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      @tc.query(ns.to_p('user'), {id: model.get('id'), action: 'list_keys'}, payload_type: ns.to_p('key')).then (keys) =>
        @set('keys', keys)
        resolve()

  actions:
    add_key: ->
      new ember.RSVP.Promise (resolve, reject) =>
        @validate().then =>
          model = @get('model')
          key   = @get('key')
          query = 
            action: 'add_key'
            id:     model.get('id')
            key:    key
            verb:   'PUT'
          @tc.query(ns.to_p('user'), query, {single: true}).then (user) =>
            @init_keys().then =>
              resolve()
        .catch =>
          reject()

  validations:
    key:
      presence:
        message: 'Please add a key.'
