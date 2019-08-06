import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import ajax  from 'totem/ajax'
import val_mixin from 'totem/mixins/validations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend val_mixin,

  init: ->
    @_super()
    @set_team_sets().then => @set_team_categories()

  # Properties
  submit_text:            ember.computed.reads 'model.submit_text'
  submit_visible:         ember.computed.reads 'model.submit_visible'
  max_score:              ember.computed.reads 'model.max_score'
  title:                  ember.computed.reads 'model.title'
  configuration_validate: ember.computed.reads 'model.configuration_validate'
  description:            ember.computed.reads 'model.description'
  auto_score:             ember.computed.reads 'model.has_auto_score'
  complete_phase:         ember.computed.reads 'model.has_complete_phase'
  unlock_phase:           ember.computed.reads 'model.has_unlock_phase'
  team_based:             ember.computed.or 'model.team_category_id', 'model.team_set_id'

  # Components
  c_validated_input: ns.to_p 'common', 'shared', 'validated_input'
  c_checkbox:        ns.to_p 'common', 'shared', 'checkbox'
  c_componentable:   ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', 'phases', 'componentable'
  c_loader:          ns.to_p 'common', 'shared', 'loader'

  # Services
  wizard_manager: ember.inject.service()
  case_manager:   ember.inject.service()
  thinkspace:     ember.inject.service()

  # Templates
  t_phase_form:      ns.to_t 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', 'phases', 'form'

  # Select Team Category
  has_team_categories:    false
  team_categories:        null
  team_category_id:       null
  team_category_selected: null

  # Select Team Set
  has_team_sets:     false
  team_sets:         null
  team_set_id:       ember.computed.reads 'model.team_set_id'
  team_set_selected: null

  # Componentables
  show_phase:            true
  current_componentable: null
  componentables_loaded: false
  has_componentables:    false

  set_team_sets: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space = @get('case_manager.current_space')
      space.get_team_sets().then (team_sets) =>
        @set 'team_sets', team_sets
        team_set_id = @get 'model.team_set_id'
        if ember.isPresent(team_set_id)
          team_set_id = "#{team_set_id}" # convert to string
          @set 'team_set_id', team_set_id 
        @set 'has_team_sets', true
        resolve()
    , (error) => console.error "[steps:phases:edit] Error in team sets find for phase edit.", error

  set_team_categories: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('case_manager').get_team_categories().then (categories) =>
        categories = categories.sortBy 'title'
        categories = categories.filter (category) => !ember.isEqual(category.get('category'), 'assessment')
        @set 'team_categories', categories
        team_category_id = @get('model.team_category_id')
        if ember.isPresent(team_category_id)
          team_category_id = "#{team_category_id}"    # convert to string
          @set 'team_category_id', team_category_id
        @set 'has_team_categories', true
        resolve()
    , (error) => console.error "[steps:phases:edit] Error in set_team_categories", error

  get_data: ->
    data =
      max_score:              @get('max_score')
      submit_text:            @get('submit_text')
      submit_visible:         @get('submit_visible')
      title:                  @get('title')
      configuration_validate: @get('configuration_validate')
      team_based:             @get('team_based')
      description:            @get('description')
      team_category_id:       @get('team_category_selected.id')
      team_set_id:            @get('team_set_selected.id')
      auto_score:             @get('auto_score')
      complete_phase:         @get('complete_phase')
      unlock_phase:           @get('unlock_phase')

  actions:
    save: ->
      phase = @get('model')
      store = @totem_scope.get_store()
      query =
        model:  phase
        id:     phase.get('id')
        action: ''
        verb:   'put'
        data:   @get_data()
      ajax.object(query).then (payload) =>
        store.pushPayload(payload)
        @send 'exit'

    cancel: ->
      phase = @get('model')
      phase.rollback() if phase.get('isDirty')
      @get('componentables').then (componentables) =>
        componentables.forEach (componentable) =>
          if typeof(componentable.admin_exit) == 'function'
            componentable.admin_exit()
          else
            componentable.unloadRecord()
        @send 'exit'

    exit: ->
      wizard_manager = @get('wizard_manager')
      assignment = wizard_manager.get_current_assignment()
      wizard_manager.transition_to_assignment_edit assignment, queryParams: { step: 'phases' }

    select_componentable: (componentable) ->
      @set 'current_componentable', componentable
      @set 'show_phase', ember.isBlank(componentable)
      @get('thinkspace').scroll_to_top()


    toggle_submit_visible:         -> @toggleProperty 'submit_visible' 
    toggle_configuration_validate: -> @toggleProperty 'configuration_validate'
    toggle_unlock_phase:           -> @toggleProperty 'unlock_phase'
    toggle_complete_phase:         -> @toggleProperty 'complete_phase'
    toggle_auto_score:             -> @toggleProperty 'auto_score'
    toggle_team_based:             -> @toggleProperty 'team_based'

  componentables: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      phase          = @get 'model'
      case_manager   = @get 'case_manager'
      phase_map      = case_manager.get_or_init_case_manager_map(phase)
      key            = 'componentables'
      componentables = phase_map.get(key)
      if ember.isPresent(componentables)
        @set_componentables_loaded(componentables)
        return resolve(componentables)  
      query =
        model:  phase
        id:     phase.get('id')
        action: 'componentables'
        verb:   'get'
      ajax.object(query).then (payload) =>
        records = ajax.extract_included_records(payload) 
        phase_map.set key, records
        @set_componentables_loaded(records)
        resolve(records)
    ta.PromiseArray.create promise: promise

  set_componentables_loaded: (records) ->
    @set 'componentables_loaded', true
    return unless ember.isPresent(records)
    records.forEach (record) =>
      @set 'has_componentables', true if ember.isPresent(record.get('edit_component'))

  validations:
    title:
      presence:    true
      modelErrors: true
    max_score:
      presence:     true
      numericality: 
        onlyInteger:          true
        greaterThanOrEqualTo: 1
        lessThanOrEqualTo:    1000
