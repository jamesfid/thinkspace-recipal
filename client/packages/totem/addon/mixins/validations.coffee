import ember from 'ember'
import ember_validations from 'ember-validations'

export default ember_validations.Mixin.reopen
  is_validation_mixin_included: true

  is_valid: ember.computed.reads 'isValid'

  # Convience function to return the ember-validations inline validator.
  inline_validator: -> ember_validations.validator

  set_validation_rules: (rules) ->
    @set_validation_rules_only(rules)
    @setup_validators()
    @validate()

  set_validation_rules_only: (rules) -> @set('validations', rules)

  # Unless the object already has the 'validations' rules object at 'init' which
  # contains all of the validators required, need to load the validators and setup
  # observers for the attributes.
  # This is a coffeescript version taken from most of the ember-validations/mixin.js 'init' function.
  setup_validators: ->
    @set 'dependentValidationKeys', {}
    @set 'validators', ember.A()
    @buildValidators()
    @validators.forEach (validator) =>
      validator.addObserver 'errors.[]', @, (sender) =>
        errors = ember.A()
        @validators.forEach (validator) =>
          if (validator.property == sender.property)
            errors.addObjects(validator.errors)
        ember.set(@, 'errors.' + sender.property, errors)

  # Helper to camelize snake_case keys in validation rules.
  camelize_validation_keys: (rules) ->
    for key, value of rules
      camel_key = key.camelize()
      unless camel_key == key
        delete(rules[key])
        rules[camel_key] = value
      rules[camel_key] = value
      @camelize_validation_keys(value) if typeof(value) == 'object'
    rules

  # ###
  # ### Model Validations.
  # ###

  # In an ideal world, the ember-validations mixin would also watch the
  # 'model.errors' object for attribute errors.
  # This may be added in future. When/if this is added, should set the model errors
  # (e.g. model.errors.add(attribute, message)) if not done by the ActiveModelAdapter.

  # The 'model_errors' custom validtor observes 'observe_validation_model_errors'
  # not the actual error in 'validation_model_errors.property-name'.
  # This allows clearing the errors without recalling the validator.
  observe_validation_model_errors: null
  validation_model_errors:         null

  add_validation_model_errors: (errors) ->
    @set 'validation_model_errors', ember.merge({}, errors)
    @notifyPropertyChange 'observe_validation_model_errors'
