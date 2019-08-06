import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  init: ->
    @_super()
    @get_lab_observation().register_component(@)
    value = @get_value()  # initial result.observation[observation_key]
    @set_input_value(value)
    @add_user_input(value)
    analysis_lo = @get_analysis_lab_observation()
    # If the analysis is correct at all AND the analysis detail key is correct (meaning user has interacted with the analysis) AND it has abnormality names
    @get_lab_observation().set_show_input(true) if analysis_lo.get('is_correct') and analysis_lo.get('detail_key_is_correct') and ember.isPresent(@get_lowercase_correct_values())
    @set 'number_of_attempts', 0


  get_lab_observation: -> @get 'lab_observation'
  get_analysis_lab_observation: -> @get_lab_observation().get_result_lab_observation_for_key('analysis')

  set_show_message: (value) -> @get_lab_observation().set_show_message(value)

  get_value:         -> @get_lab_observation().get_value()
  set_value: (value) -> @get_lab_observation().set_value(value)

  set_lab_observation_value: -> @set_value @get_input_value()

  get_result:  -> @get_lab_observation().get_result()
  save_result: -> @get_lab_observation().save_result()

  get_input_value:         -> @get 'input_value'
  set_input_value: (value) -> @set 'input_value', value

  add_user_input: (input)         -> @get_lab_observation().add_user_input(input)
  get_entered_user_input: (input) -> @get_lab_observation().entered_user_input(input)

  add_to_observation_list: (input) -> @get_lab_observation().add_to_observation_list(input)

  get_max_attempts: -> @get_lab_observation().get_max_attempts()

  focus_self:        -> @$('input').focus()
  focus_next_result: -> @get_lab_observation().set_focus_on_next_result()

  get_error_message:           -> @get_lab_observation().get_error_message()
  set_error_message: (message) -> @get_lab_observation().set_error_message(message)
  clear_error_message:         -> @get_lab_observation().clear_error_message()

  # ###
  # ### Correct Values.
  # ###
  is_correct: null

  correct_input: (input) ->
    return false if ember.isBlank(input)
    @get_lowercase_correct_values().contains(input.toLowerCase())

  get_lowercase_correct_values: -> @get('correct_values').map (val) -> val.toLowerCase()
  get_lowercase_user_values:    -> @get_lab_observation().get_user_inputs()
  
  get_correct_entered_user_input: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @set 'lowercase_correct_values', @get_lowercase_correct_values()
      @set 'lowercase_input_values',   @get_lowercase_user_values()
      ember.run.next =>
        values = @get('intersect_values')
        return null if ember.isBlank(values)
        input = values.get('firstObject')
        resolve @get_entered_user_input(input)

  lowercase_correct_values: []
  lowercase_input_values:   []
  intersect_values:         ember.computed.intersect 'lowercase_correct_values', 'lowercase_input_values'

  correct_link_text: ember.computed -> @get_lab_observation().show_correct_values_text()
  correct_values:    ember.computed -> ember.makeArray(@get_lab_observation().get_result_value 'validate.correct')
  show_correct:      ember.computed 'number_of_attempts', ->
    return if @get('is_correct')
    @get('number_of_attempts') >= @get_max_attempts()

  incorrect_text: ember.computed 'number_of_attempts', -> @get_lab_observation().show_incorrect_text() + " - attempt: [#{@get('number_of_attempts')}]"
  show_incorrect: ember.computed 'number_of_attempts', ->
    return if @get('is_correct')
    0 < @get('number_of_attempts') < @get_max_attempts()

  show_input:          null
  show_correct_values: null
  number_of_attempts:  null
  is_another_event:    null

  input_value: null

  # Note: Leaving this in for now, but right now it works by focusIn and enter only.
  # focusOut: ->
  #   console.warn '>>>>INPUT FOCUS OUT:', 'attempts:', @get('number_of_attempts')
  #   if @get('is_another_event')
  #     @set 'is_another_event', false
  #   else
  #     input = @get_input_value()
  #     @set_lab_observation_value()
  #     @incrementProperty('number_of_attempts')
  #     if @correct_input(input)
  #       @set 'is_correct', true
  #       @add_user_input(input)
  #       @add_to_observation_list(input)
  #       @save_result()
  #     else
  #       @focus_self()

  focusIn: ->
    @get_lab_observation().set_focused()
    @get_correct_entered_user_input().then (correct_value) =>
      return unless ember.isPresent(correct_value)
      @set 'is_correct', true
      # Note: Without the run.next IE will not correctly set the input value.  It will be disabled, but have a blank entry.
      ember.run.next =>
        @set_input_value(correct_value) 
        @save_input_result()

  keyDown: (e) ->
    if ember.isEqual(e.keyCode, 13)
      input = @get_input_value()
      @incrementProperty('number_of_attempts')
      if @correct_input(input)
        @set 'is_correct', true
        @save_input_result(input)
      else
        @focus_self()

  save_input_result: (input=null) ->
    @show_save_retry_message()
    ember.run.next =>
      @set_lab_observation_value()
      @save_result().then =>
        if input
          @add_user_input(input)
          @add_to_observation_list(input)
        @focus_next_result()
        @clear_error_message()
      , (error) =>
        @reset_event_and_show_save_error()

  reset_event_and_show_save_error: ->
    @set 'is_another_event', false
    @show_save_error_message()

  show_save_error_message: -> @set_error_message "Could not save result. Please try again."

  show_save_retry_message: ->
    return unless @get_error_message()
    @set_error_message "Retrying save."

  actions:
    show_correct_values: -> @set 'show_correct_values', true
