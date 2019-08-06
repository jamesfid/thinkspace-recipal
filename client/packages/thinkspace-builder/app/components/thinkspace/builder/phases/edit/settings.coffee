import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-builder/components/wizard/steps/base'

export default base.extend
  # ### Abilities
  totem_data_config: ability: {ajax_source: true, ajax_method: 'builder_abilities'}

  # ### Properties
  model:       null
  has_changes: false

  # Team properties
  team_sets:              null
  team_categories:        null

  selected_team_set:      null
  selected_team_category: null

  # State properties
  default_states: [{id: 'unlocked', display: 'Unlocked'}, {id: 'locked', display: 'Locked'}]

  # ### Computed properties
  max_score:              ember.computed.reads 'model.max_score'
  configuration_validate: ember.computed.reads 'model.configuration_validate'
  auto_score:             ember.computed.reads 'model.has_auto_score'
  complete_phase:         ember.computed.reads 'model.has_complete_phase'
  unlock_phase:           ember.computed.reads 'model.has_unlock_phase'
  default_state_locked:   ember.computed.equal 'model.default_state', 'locked'

  selected_team_set_id:      ember.computed.reads 'model.team_set_id'
  selected_team_category_id: ember.computed.reads 'model.team_category_id'

  # Team
  is_team_based:       ember.computed.or 'selected_team_set_id', 'selected_team_category_id'
  has_team_sets:       ember.computed.notEmpty 'team_sets'
  has_team_categories: ember.computed.notEmpty 'team_categories'

  # ### Components
  c_checkbox: ns.to_p 'common', 'shared', 'checkbox'
  c_dropdown: ns.to_p 'common', 'dropdown'

  # ### Observers
  confirmation_observer: ember.observer 'is_team_based', 'auto_score', 'configuration_validate', 'max_score', -> @set_has_changes()

  # ### Events
  init: ->
    @_super()
    @totem_data.ability.unload()
    @set_team_sets().then => @set_team_categories().then => 
      @set_selected_team_set().then => @set_selected_team_category().then =>
        console.info "[builder] Phase settings component: ", @
        @set_all_data_loaded()


  # ### Team set promises (team sets, categories)
  set_team_sets: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('builder').get_space().then (space) =>
        space.get_team_sets().then (team_sets) =>
          @set 'team_sets', team_sets
          resolve()
        , (error) => @error(error)
      , (error) => @error(error)
    , (error) => @error(error)

  set_team_categories: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('team_category')).then (team_categories) =>
        @set 'team_categories', team_categories
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  set_selected_team_set: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_set_id = @get 'selected_team_set_id'
      if ember.isPresent(team_set_id)
        @tc.find_record(ns.to_p('team_set'), team_set_id).then (team_set) =>
          @set 'selected_team_set', team_set
          resolve()
        , (error) => @error(error)
      else
        resolve()
    , (error) => @error(error)

  set_selected_team_category: ->
    new ember.RSVP.Promise (resolve, reject) =>
      team_category_id = @get 'selected_team_category_id'
      if ember.isPresent(team_category_id)
        @tc.find_record(ns.to_p('team_category'), team_category_id).then (team_category) =>
          @set 'selected_team_category', team_category
          resolve()
        , (error) => @error(error)
      else
        resolve()
    , (error) => @error(error)

  # ### Helpers
  get_configuration_values: ->
    values = 
      max_score:              @get('max_score')
      configuration_validate: @get('configuration_validate')
      team_based:             @get('team_based')
      auto_score:             @get('auto_score')
      complete_phase:         @get('complete_phase')
      unlock_phase:           @get('unlock_phase')

  set_has_changes:   -> @set 'has_changes', true
  reset_has_changes: -> @set 'has_changes', false

  exit: ->
    # TODO: Need to use Totem Verify to ensure they want to lose their changes.
    has_changes = @get 'has_changes'
    if has_changes
      confirm = window.confirm('Are you sure you want to exit?  You have made unsaved changes.')
      return unless confirm
      @sendAction 'back'
    else
      @sendAction 'back'

  model_state_change: (action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      return unless ember.isPresent(model)
      @totem_messages.show_loading_outlet()
      return unless model[action]?
      model[action]().then (phase) =>
        @totem_messages.hide_loading_outlet()
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  actions:
    activate:   -> @model_state_change('activate')
    archive:    -> @model_state_change('archive')
    inactivate: -> @model_state_change('inactivate')

    save: ->
      phase         = @get 'model'
      is_team_based = @get 'is_team_based'
      default_state = if @get('default_state_locked') then 'locked' else 'unlocked'
      ns_phase      = ns.to_p('phase')
      store         = @totem_scope.get_store()
      query         = 
        id:               phase.get 'id'
        action:           ''
        verb:             'put'
        configuration:    @get_configuration_values()
        "#{ns_phase}":
          default_state: default_state

      # If they disable team_based, remove the team set and team category.
      if is_team_based
        query[ns_phase].team_set_id      = @get 'selected_team_set.id'
        query[ns_phase].team_category_id = @get 'selected_team_category.id' 
      else
        query[ns_phase].team_set_id = null
        query[ns_phase].team_category_id = null

      @totem_messages.show_loading_outlet()
      @tc.query(ns.to_p('phase'), query, single: true).then (phase) =>
        @reset_has_changes()
        @totem_messages.hide_loading_outlet()
        @exit()

    cancel:                        -> @exit()

    toggle_is_team_based:          ->
      return unless @get('can.team_based')
      @toggleProperty 'is_team_based'
    toggle_auto_score:             ->
      return unless @get('can.auto_score')
      @toggleProperty 'auto_score'
    toggle_unlock_phase: ->
      return unless @get('can.unlock_phase')
      @toggleProperty 'unlock_phase'
    toggle_configuration_validate: ->
      return unless @get('can.configuration_validate')
      @toggleProperty 'configuration_validate'
    toggle_default_state_locked: ->
      return unless @get('can.default_state')
      @toggleProperty 'default_state_locked'
