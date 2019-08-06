import base  from 'ember-validations/validators/base'
import ember from 'ember'

export default base.extend
  smaller_property: null # Dependent
  larger_property:  null

  init: ->
    @_super()
    smaller_property = @options.smaller_property
    larger_property  = @options.larger_property
    message          = @options.message
    
    @set 'smaller_property', smaller_property
    @set 'larger_property', larger_property
    @set 'message', message
    
    @dependentValidationKeys.pushObject smaller_property
    @dependentValidationKeys.pushObject larger_property

  call: ->
    ## This validator should be used along with presence validators. If either of the parameters is null, we return valid.
    model            = @get 'model'
    smaller_property = @get 'smaller_property'
    larger_property  = @get 'larger_property'
    message          = @get 'message'
    smaller_value    = model.get smaller_property
    larger_value     = model.get larger_property

    if smaller_value > larger_value
      @errors.pushObject(message)