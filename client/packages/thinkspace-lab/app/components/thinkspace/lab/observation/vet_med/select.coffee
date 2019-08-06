import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  init: ->
    @_super()
    @set 'is_init', true
    @get_lab_observation().register_component(@)
    value = @get_value() or @get_normal_value() # initial result.observation[observation_key]'
    @set_value value
    @set 'selected', @get_lab_observation().get_selections().findBy('id', value)
    @set 'selection', value.capitalize()

  # ### Components
  c_dropdown:      ns.to_p 'common', 'dropdown'

  get_lab_observation: -> @get 'lab_observation'

  get_value:         -> @get_lab_observation().get_value()
  set_value: (value) -> @get_lab_observation().set_value(value)

  get_normal_value:  -> @get_lab_observation().get_normal_value()
  get_correct_value: -> @get_lab_observation().get_correct_value()

  set_lab_observation_value: -> @set_value @get_selected_id()

  get_result:  -> @get_lab_observation().get_result()
  save_result: -> @get_lab_observation().save_result @get_result()

  get_selected_id: -> @get('selected.id')

  get_abnomality_lab_observation: -> @get_lab_observation().get_result_lab_observation_for_key('abnormality')

  focus_self:        -> @$('.ts-lab_select').focus()
  focus_next_result: -> @get_lab_observation().set_focus_on_next_result()

  get_error_message:           -> @get_lab_observation().get_error_message()
  set_error_message: (message) -> @get_lab_observation().set_error_message(message)
  clear_error_message:         -> @get_lab_observation().clear_error_message()

  selections: ember.computed -> @get_lab_observation().get_selections()

  is_another_event: null
  is_correct:       null

  selection: null  # initial selection value from the observation
  selected:  null  # user selected value object (id: 'myid', label: 'My Label')

  didInsertElement: ->
    @$('option').on 'click', (e) => @process_option_click(e)

  focusIn: (event) -> @get_lab_observation().set_focused()

  keyPress: (event) ->
    key_code = event.keyCode
    switch key_code
      when 13 # Enter
        @save_selected()
      else
        char_code = event.which || event.charCode || event.keyCode
        return unless char_code
        value         = String.fromCharCode(char_code).toLowerCase()
        selections    = @get('selections')
        selection_ids = selections.mapBy 'id'
        selected_ids  = selection_ids.filter (id) -> id and util.starts_with(id, value)
        return if selected_ids.get('length') != 1  # more than one match
        selected_id = selected_ids.get('firstObject')
        return unless selected_id
        selected = selections.findBy 'id', selected_id
        return unless selected
        @set 'selected', selected
        @set 'selection', selected.label
        @save_selected()

  process_option_click: (e) ->
    selected = @get 'selected.id'
    clicked  = @$('option:selected').val()
    @propertyDidChange('selected') if ember.isEqual(selected, clicked)

  show_input_and_focus: ->
    lo      = @get_abnomality_lab_observation()
    correct = lo.get_correct_value()
    if ember.isPresent(correct) # Do not show input if there is no abnormality.
      lo.set_show_input(true)
      lo.focus_self()
    else
      @focus_next_result()

  save_selected: ->
    @set_lab_observation_value()
    value   = @get_value()
    correct = @get_correct_value()
    normal  = @get_normal_value()
    @set 'is_correct', (value == correct)
    switch
      when value == correct  and value == normal   then @save_select_result @get_abnomality_lab_observation()
      when correct == normal and value != correct  then @save_select_result()
      when value != correct                        then @save_select_result()
      else @save_select_result @get_abnomality_lab_observation()

  save_select_result: (lo=null) ->
    @show_save_retry_message()
    @save_result().then =>
      @clear_error_message()
      if lo then @show_input_and_focus() else @focus_next_result()
    , (error) =>
      @show_save_error()

  # save_and_show_input: ->
  #   lo = @get_abnomality_lab_observation()
  #   # If this is not `then`, it will duplicate save on the focusIn event of the input.
  #   # => This causes the 'id already in store cannot reset' error and duplicates the record.
  #   # => Usability wise, it's smoother when this is not `then`, but this ensures the double save cannot happen.
  #   # => The original method (saving only on abnormality name) could potentially be used if needed.
  #   @show_save_retry_message()
  #   @save_result().then => 
  #     @show_input_and_focus()
  #     @clear_error_message()
  #   , (error) =>
  #     @reset_event_and_show_save_error()

  show_save_error: ->
    @set('is_another_event', false)
    @show_save_error_message()

  show_save_error_message: -> @set_error_message "Could not save result. Please try again."

  show_save_retry_message: ->
    return unless @get_error_message()
    @set_error_message "Retrying save."

  actions:
    select: (option) -> 
      @set 'selection', option.label
      @set 'selected', option
      @save_selected()