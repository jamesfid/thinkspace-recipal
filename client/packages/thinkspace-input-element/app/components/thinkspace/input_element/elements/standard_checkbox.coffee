import ember from 'ember'
import ns from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend val_mixin,
  tagName: ''

  view_only: ember.computed.bool 'totem_scope.is_view_only'

  is_checked: ember.computed (key, value) ->
    unless value?
      @get('model.value') == 'true'
    else
      @set 'model.value', value.toString()
      @save_response()
      value == true

  save_response: ->
    model = @get('model')
    @totem_scope.set_record_ownerable_attributes(model)
    model.save().then =>
      @totem_messages.api_success(source: @, model: model, action: 'save', i18n_path: ns.to_o('response', 'save'))
    , (error) => 
      @totem_messages.api_failure(error, source: @, model: model)
