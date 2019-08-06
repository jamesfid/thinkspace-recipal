import ember from 'ember'
import ns from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend val_mixin,
  # ### Properties
  tagName: ''
  input_value: null

  # ### Computed properties
  view_only:  ember.computed.bool 'totem_scope.is_view_only'
  is_checked: ember.computed 'model.value', -> @get('radio_value') ==  @get('model.value')

  actions:
    check: ->
      return if @get('is_view_only')
      model = @get('model')
      value = @get('radio_value')
      @set 'input_value', value
      @set_status().then =>
        model.set 'value', value
        @save_response()
      , => return

  save_response: ->
      model = @get('model')
      @totem_scope.set_record_ownerable_attributes(model)
      model.save().then =>
        @totem_messages.api_success(source: @, model: model, action: 'save', i18n_path: ns.to_o('response', 'save'))
      , (error) => 
        @totem_messages.api_failure(error, source: @, model: model)

  set_status: -> @get('status').validate(@, @get('status_group_guid'))  # returns a promise: resolve=valid; reject=invalid

  didInsertElement: ->
    @set 'input_value', @get('model.value')
    @set_status()
