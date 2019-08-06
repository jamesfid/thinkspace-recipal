import ember from 'ember'
import totem_scope from 'totem/scope'

export default ember.Object.extend

  init: ->
    @_super()
    @set 'totem_scope', totem_scope
    value = @get_observation_value()  # initial result.observation[observation_key] value
    @set_value(value)                 # set the initial observation value on this object (if the observation record does not yet exist, will be undefined)
    @define_observation_properties()
    @get_lab().register_lab_observation(@)
    @get_lab_result().register_lab_observation(@)

  define_observation_properties: ->
    detail_key = "result.observation.detail.#{@get_observation_key()}"
    ember.defineProperty @, 'is_correct', ember.computed.or 'component.is_correct', "#{detail_key}.correct", 'normal_is_correct', 'result.observation.all_correct'
    ember.defineProperty @, 'detail_key_is_correct', ember.computed.or "#{detail_key}.correct", 'result.observation.all_correct'


  register_component: (component) -> @set 'component', component

  # ###
  # ### Helpers.
  # ###

  get_lab:             -> @get 'lab'
  get_lab_result:      -> @get 'lab_result'
  get_result:          -> @get 'result'
  get_component:       -> @get 'component'
  get_observation_key: -> @get 'observation_key'

  # Observation value on this object e.g. not in the observation record.
  get_value:           -> @get 'observation_value'
  set_value: (value)   -> @set 'observation_value', value

  get_observation_value:               -> @get("result.observation.value.#{@get_observation_key()}")
  get_observation_detail_value: (path) -> @get("result.observation.detail.#{@get_observation_key()}.#{path}")

  get_observation_detail_attempts: -> @get_observation_detail_value('attempts') or 0

  get_category_value: (path) -> @get_lab().get_value(@get_observation_key(), path)
  get_result_value: (path)   -> @get("result.values.observations.#{@get_observation_key()}.#{path}")

  get_result_lab_observation_for_key: (key) -> @get_lab().get_result_lab_observation_for_key @get_result(), key

  get_correct_value: -> @get_result_value 'validate.correct'

  # ###
  # ### Disable Input.
  # ###

  error_message: null
  get_error_message:           -> @get 'error_message'
  set_error_message: (message) -> @set 'error_message', message
  clear_error_message:         -> @set 'error_message', null

  is_view_only: ember.computed.bool 'totem_scope.is_view_only'
  is_disabled:  ember.computed 'is_correct', 'is_view_only', 'error_message', ->
    return true  if @get('is_view_only')
    return true  if @get('normal_is_correct') and @get('user_has_interacted')
    return false if @get('normal_is_correct')
    return false if @get('error_message')
    @get('is_correct')

  # ###
  # ### Focus.
  # ###
  set_focus_on_selected_category: -> @get_lab().set_focus_on_selected_category()
  set_focus_on_next_result:       -> @get_lab().set_focus_on_next_result @get_result()
  set_focused:                    -> @get_lab_result().set_focused()

  focus_self: -> ember.run.schedule 'afterRender', @, => 
    component = @get_component()
    component.focus_self() if component.focus_self?

  # ###
  # ### Save/Validate.
  # ###
  save_result: -> @get_lab().save_result(@get_result(), @)

  get_is_correct:  -> @get 'is_correct'
  get_is_disabled: -> @get 'is_disabled'

  after_save: -> return

  # ###
  # ### Select Only.
  # ###
  get_selections:   -> @get_result_value('selections')
  get_normal_value: -> @get_result_value('normal')

  normal_is_correct: ember.computed 'result', ->
    value   = @get_value()
    correct = @get_correct_value()
    normal  = @get_normal_value()
    ember.isEqual(correct, normal) and ember.isEqual(value, correct)

  user_has_interacted: ember.computed 'normal_is_correct', 'detail_key_is_correct', 'component.is_correct', ->
    normal_is_correct = @get('normal_is_correct')
    return false unless normal_is_correct
    normal_is_correct and (@get('detail_key_is_correct') or @get('component.is_correct'))

  normal_is_correct_without_interaction: ->
    correct = @get_correct_value()
    normal  = @get_normal_value()
    ember.isEqual(correct, normal)


  # ###
  # ### Input Only.
  # ###
  get_user_inputs:            -> @get_lab().get_user_inputs @get_observation_key()
  add_user_input:  (input)    -> @get_lab().add_user_input  @get_observation_key(), input
  entered_user_input: (input) -> @get_lab().entered_user_input @get_observation_key(), input

  get_max_attempts:         -> @get_result_value 'max_attempts'
  show_correct_values_text: -> 'Click for correct values.'
  show_incorrect_text:      -> 'Incorrect, please try again.'
  
  add_to_observation_list: (input) -> @get_lab().add_to_observation_list(input)

  show_input: null
  set_show_input: (value) -> @set 'show_input', value

  # ###
  # ### Correctable Only.
  # ###
  get_correctable_prompt:      -> @get_category_value('correctable_prompt')
  get_correctable_placeholder: -> @get_category_value('correctable_placeholder')

  toString: -> 'LabObservation'
