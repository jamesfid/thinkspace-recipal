import ember from 'ember'
import ns    from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend val_mixin,
  layoutName: ns.to_t('gradebook', 'phase/score')

  input_score: null
  score_from:  null
  score_to:    null

  phase_score_validation: ember.computed.reads 'current_phase.configuration.settings.phase_score_validation'

  actions:      
    save: ->
      return unless @get('is_valid')
      @sendAction 'save', @get('input_score')
      @set 'input_score', null

  set_focus:  -> @$('input').focus()

  didInsertElement: ->
    @set_score_validations()
    @set_focus()
    @sendAction 'view', @

  # The score's validation rules.
  # Validation rules are defined in the phase's configuration model or get the defaults.
  default_score_validation:
    numericality: 
      only_integer:             false
      greater_than_or_equal_to: 1
      less_than_or_equal_to:    10
      allow_blank:              true
      decimals:                 0

  set_score_validations: ->
    phase_rules = @get('phase_score_validation') or @get('default_score_validation')
    rules       = JSON.parse(JSON.stringify phase_rules)  # hacky way to convert to a plain js object
    rules       = @camelize_validation_keys(rules)
    [from, to]  = [null, null]
    if rules.numericality
      rules.inline = @numericality_decimals_validator(rules.numericality.decimals)
      [from, to]   = @get_score_from_and_to(rules.numericality)
    @set 'score_from', from
    @set 'score_to', to
    @set_validation_rules(input_score: rules)

  numericality_decimals_validator: (number_of_decimals=0) ->
    @inline_validator() ->
      value = @get('input_score')
      return null unless value
      [v, digits] = ('' + value).split('.')
      decimals    = (digits and digits.length) or 0
      scale       = number_of_decimals
      if (decimals > scale)
        if (scale <= 0) then "decimals are not allowed" else "decimals must be less than #{scale}"
      else
        null

  get_score_from_and_to: (options={}) ->
    switch
      when options.greaterThan?          then from = options.greaterThan + 1
      when options.greaterThanOrEqualTo? then from = options.greaterThanOrEqualTo
      else from = null
    switch
      when options.lessThan?          then to = options.lessThan - 1
      when options.lessThanOrEqualTo? then to = options.lessThanOrEqualTo
      else to = null
    [from, to]
