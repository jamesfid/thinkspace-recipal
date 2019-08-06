import ember from 'ember'
import base from 'ember-validations/validators/base'

# This custom validator will be part of the 'isValid' property for server-based model errors
# and the 'isValid' or 'is_valid' property can be used in templates (e.g. show/hide save button).
# Either 'model_errors' or 'modelErrors' will wosrk in the 'validations' object.
# The errors are cleared after the first reference, so the 'model_errors' will be false
# for the 'isValid' check when re-validated.

# The only option used is 'withKey'.  When true, prefixes the message with the key (defaults to false).
# Examples:
# validations:
#  title:
#    modelErrors: true  #=> create messages without key prefix
#    modelErrors:
#      withKey: true    #=> add key prefix to message

export default base.extend

  init: ->
    @_super()
    # The validations mixin will notify a property change on 'observe_validation_model_errors'
    # after setting the model errors e.g. 'not' observing 'valiation_model_errors.property-name'.
    @dependentValidationKeys.pushObject("observe_validation_model_errors")

  call: ->
    with_key = @options.withKey or false
    prop     = @property.split('.').pop()
    path     = "validation_model_errors.#{prop}"

    if prop_errors = @get(path)
      if with_key
        @errors.pushObject "#{prop} #{msg}"  for msg in prop_errors
      else
        @errors.pushObject msg for msg in prop_errors
      # Once the message is added, clear the error so when the user changes the field, this error will disappear.
      # NOTE: This is 'not' the property being observed, so can clear without recalling this validator.
      @set path, null
