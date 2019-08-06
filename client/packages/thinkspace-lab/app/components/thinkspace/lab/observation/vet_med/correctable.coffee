import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  is_correct:         null
  input_value:        null
  correction_visible: false
  prompt_correct:     ember.computed -> @get_lab_observation().get_category_value('correctable_prompt')
  correct_value:      ember.computed -> @get_lab_observation().get_result_value 'validate.correct' 
  max_attempts:       ember.computed -> @get_lab_observation().get_result_value 'max_attempts' 
  show_help:          ember.computed 'number_of_attempts', -> @get('number_of_attempts') >= @get('max_attempts')

  help_observer: ember.observer 'number_of_attempts', ->
    show_help = @get 'show_help'
    @show_help_modal() if show_help

  init: ->
    @_super()
    @get_lab_observation().register_component(@)
    value = @get_value()  # initial result.observation[observation_key]
    @set_input_value(value)
    @set 'correction_visible', true  if value
    @set 'number_of_attempts', 0

  get_help_modal:   -> $('.ts-lab_modal')
  show_help_modal:  -> @get_help_modal().foundation('reveal', 'open')

  get_lab_observation: -> @get 'lab_observation'

  get_value:         -> @get_lab_observation().get_value()
  set_value: (value) -> @get_lab_observation().set_value(value)

  set_lab_observation_value: -> @set_value @get_input_value()

  get_result:  -> @get_lab_observation().get_result()

  get_input_value:         -> @get 'input_value'
  set_input_value: (value) -> @set 'input_value', value

  save_result: ->
    correct_value = parseFloat(@get('correct_value'))
    input_value   = parseFloat(@get_input_value())
    if ember.isEqual(correct_value, input_value)
      @set 'is_correct', true
      @get_lab_observation().save_result @get_result()
    else
      @incrementProperty 'number_of_attempts'

  focus_next_result: -> @get_lab_observation().set_focus_on_next_result()

  focus_self: ->
    ember.run.next =>
      if @get('correction_visible') then @$('input').focus() else @focus_next_result()

  enable_correction_input: ->
    @set('correction_visible', true)
    @focus_self()

  keyPress: (e) ->
    $target  = $(e.target)
    tag_name = $target.prop('tagName').toLowerCase()
    switch tag_name
      when 'input'
        @set_lab_observation_value()
        @save_result() if ember.isEqual(e.keyCode, 13)
      when 'a'
        @enable_correction_input()

  actions:
    show: -> @enable_correction_input()
    set_input_value: -> @set_lab_observation_value()
    save: -> @save_result()
    cancel: ->
      @set 'input_value', null
      @set 'correction_visible', false
    close_help_modal: -> @get_help_modal().foundation('reveal', 'close')
