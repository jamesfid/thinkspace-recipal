import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

# tvo bound attributes on component creation (tvo paths set in view_generator):
#  model:       [response model]
#  tattr:       [hash] input tag attributes 
#  validations: [hash] validation rules object
#  show_errors: [true|false]
#  status:      [object] status object to collect status values

export default base_component.extend val_mixin,
  classNames:        ['thinkspace-ie']
  classNameBindings: ['input_class_name']

  tvo: ember.inject.service()

  init: ->
    @_super()
    @get('tvo.status').register_validation('inputs', @, 'validate_input_saved')

  input_class_name: ember.computed 'is_valid', 'totem_scope.is_view_only', ->
    return null if @get('is_valid') or @totem_scope.get('is_view_only')
    'thinkspace-ie_error'

  input_value: null

  focusOut: ->
    @set_status().then =>
      @save_response()
    , => return

  save_response: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.set 'value', @get('input_value')
      @totem_scope.set_record_ownerable_attributes(model)
      model.save().then =>
        @totem_messages.api_success source: @, model: model, action: 'save', i18n_path: ns.to_o('response', 'save')
        resolve()
      , (error) => 
        @totem_messages.api_failure error, source: @, model: model
        reject(error)

  set_status: -> @get('status').validate(@)  # returns a promise: resolve=valid; reject=invalid

  # Work around for ember-validations using Components (e.g. does not proxy properties).
  # The input binds to 'this.input_value' rather than the model.value.
  didInsertElement: ->
    @set 'input_value', @get('model.value')
    @set_status()

  validate_input_saved: (status) ->
    new ember.RSVP.Promise (resolve, reject) =>
      status.set_is_valid(true)
      return resolve()  unless @get('is_valid')  # input not valid so just return
      model = @get('model')
      return resolve() unless ( model.get('isDirty') and not model.get('isNew') )
      @save_response().then => resolve()
