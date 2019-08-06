import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'

export default ember.Object.extend
  init: ->
    @_super()
    @set 'user_inputs', {}
    @set 'user_input_map', {}
    @set 'lab_results', []

  register_lab_observation: (result) -> @get_lab_observations().pushObject(result)
  register_lab_result:      (result) -> @get_lab_results().pushObject(result)

  get_value: (key, path)                      -> @get_category_observation_value(key, path) or @get_category_value(path)
  get_category_observation_value: (key, path) -> @get("category.value.observations.#{key}.#{path}")
  get_category_value: (path)                  -> @get("category.value.#{path}")

  # ###
  # ### Lab Result Helpers.
  # ###

  get_lab_observations: -> @get('lab_observations')
  get_lab_results:      -> @get('lab_results')
  get_results:          -> (@get_lab_observations().mapBy 'result').uniq()

  get_lab_observations_for_result: (result) -> @get_lab_observations().filterBy 'result', result

  get_result_lab_observation_for_key: (result, key) -> (@get_lab_observations_for_result(result).filterBy 'observation_key', key).get('firstObject')

  # ###
  # ### Create Observation List Observation.
  # ###

  add_to_observation_list: (value) ->
    tvo           = @get 'tvo'
    section       = 'obs-list'
    create_action = 'select-text'
    list_action   = 'obs-list-values'
    if tvo.section.has_action(section, list_action)
      tvo.section.call_action(section, list_action).then (values) =>
        return if values.contains(value)
        if tvo.section.has_action(section, create_action)
          tvo.section.send_action(section, create_action, value)

  # ###
  # ### Save Observation.
  # ###

  save_all: -> @get_results().forEach (result) => @save_result(result)

  save_result: (result, saving_lab_observation) ->
    new ember.RSVP.Promise (resolve, reject) =>
      lab_observations = @get_lab_observations_for_result(result)
      return resolve() if ember.isBlank(lab_observations)  # no observation values defined in the result
      @get_result_observation(result).then (observation) =>
        return resolve() if @skip_observation_save(observation)
        lab_observations.map (lab_observation) => @set_observation_lab_observation_value(observation, lab_observation)
        @save_observation(observation).then =>
          lab_observations.map (lab_observation) => lab_observation.after_save(saving_lab_observation)
          resolve()
        , (error) =>
          reject(error)

  get_result_observation: (result) ->
    new ember.RSVP.Promise (resolve, reject) =>
      observation = result.get('observation')
      unless observation
        observation = result.store.createRecord ns.to_p('lab:observation'), locked: false, value: {}
        @totem_scope.set_record_ownerable_attributes(observation)
        observation.set ns.to_p('lab:result'), result
      resolve(observation)

  save_observation: (observation) ->
    new ember.RSVP.Promise (resolve, reject) =>
      # console.warn 'save observation value', observation.get('value')
      observation.save().then =>
        @totem_messages.api_success source: @, model: observation, i18n_path: ns.to_o('lab:observation', 'save')
        resolve()
      , (error) =>
        # @totem_messages.api_failure error, source: @, model: observation
        reject(error)

  set_observation_lab_observation_value: (observation, lab_observation) ->
    key   = lab_observation.get_observation_key()
    value = lab_observation.get_value()
    observation.set "value.#{key}", value

  skip_observation_save: (observation) ->
    is_new      = observation.get('isNew')
    return false if is_new
    locked      = observation.get('state') == 'locked'
    all_correct = observation.get('all_correct')
    locked or all_correct

  # ###
  # ### Focus.
  # ###

  set_focus_on_selected_category: (tag=null) ->
    ember.run.schedule 'afterRender', @, => 
      lab_observation = @get_lab_observations().findBy 'is_disabled', false
      lab_observation and @set_focus(lab_observation, tag)

  set_focus: (lab_observation, tag=null) ->
    return unless lab_observation
    component     = lab_observation.get_component()
    $next_element = (tag and component.$(tag)) or component.$(':input') # :input matches both 'input' and 'select' tags
    $next_element.focus()

  set_focus_on_next_result: (result) ->
    return unless result
    lab_observation  = @get_lab_observations_for_result(result).get('lastObject')
    return unless lab_observation
    lab_observations = @get_lab_observations()
    index            = lab_observations.indexOf(lab_observation)
    return unless index?
    next = lab_observations.slice(index + 1).findBy 'is_disabled', false
    if next then next.focus_self() else @set_focus_on_selected_category()

  # ###
  # ### User Inputs.
  # ###

  get_user_inputs: (key) -> @get("user_inputs.#{key}")

  add_user_input: (key, input) ->
    return if ember.isBlank(input)
    inputs  = @get('user_inputs')
    kv      = inputs[key] = []  unless (kv = inputs[key])
    l_input = @convert_to_lowercase(input)
    return if kv.contains(l_input)
    kv.push(l_input)
    map  = @get('user_input_map')
    kmap = map[key] = {}  unless (kmap = map[key])
    hash = {}
    hash.input    = input
    kmap[l_input] = hash

  entered_user_input: (key, input) ->
    return null unless (key and input)
    l_input = @convert_to_lowercase(input)
    @get("user_input_map.#{key}.#{l_input}.input")

  convert_to_lowercase: (string) ->
    return '' unless typeof(string) == 'string'
    string.toLowerCase()

  # ###
  # ### Validate Lab Observations.
  # ###

  validate_lab_observations: (status) ->
    messages = []
    status.set_is_valid(true)
    @get_lab_observations().forEach (lo) =>
      # Allow for the 'normal is correct' scenario to pass without user interaction.
      nic         = lo.normal_is_correct_without_interaction()
      is_correct  = lo.get_is_correct()
      has_correct = lo.get_correct_value() # If null, no correct answer (e.g. abnormalities for normal is correct scenario)
      switch
        when !has_correct # No valid answer given, assume correct.
          status.increment_valid_count()
        when nic # Default is normal, and normal is correct.
          status.increment_valid_count()
        when is_correct # Actual value entered is correct.
          status.increment_valid_count()
        else
          status.set_is_valid(false)
          status.increment_invalid_count()
          messages.push lo.get_result().get('description')
    status.set_status_messages messages.uniq()

  toString: -> 'Lab'
