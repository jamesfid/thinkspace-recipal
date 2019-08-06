import ember from 'ember'
import ns         from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  layoutName: 'thinkspace/common/user/password/new'

  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_loader:          ns.to_p 'common', 'shared', 'loader'

  authenticating: false

  actions:
    submit: ->
      model = @get('model')
      @set 'authenticating', true
      model.save().then (response) =>
        @set 'authenticating', false
        @sendAction 'goto_users_password_confirmation'
