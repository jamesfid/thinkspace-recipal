import ember                 from 'ember'
import ta                    from 'totem/ds/associations'
import tc                    from 'totem/cache'
import resource_mixin        from 'thinkspace-resource/mixins/resources'
import included_models_mixin from 'totem-application/mixins/included_models'

export default ta.Model.extend ta.totem_data, resource_mixin, included_models_mixin, ta.add(
    ta.belongs_to 'space',  reads: {}
    ta.has_many   'phases', reads: {sort: 'position:asc'}
  ), 
  title:            ta.attr('string')
  description:      ta.attr('string')
  active:           ta.attr('boolean')
  instructions:     ta.attr('string')
  name:             ta.attr('string')
  template_id:      ta.attr('number')
  bundle_type:      ta.attr('string')
  state:            ta.attr('string')
  release_at:       ta.attr('date') # Non-ownerable release_at
  due_at:           ta.attr('date') # Non-ownerable due_at
  settings:         ta.attr()
  included_options: ta.attr() # TODO: Remove in favor of included.records/options?
  # ### TEMPORARY FOR NEW BUILDER
  builder_version:     ta.attr('number')
  builder_template_id: ta.attr('number')

  is_active:      ember.computed.equal 'state', 'active'
  is_inactive:    ember.computed.equal 'state', 'inactive'

  ttz: ember.inject.service()

  totem_data_config: ability: true, metadata: true

  default_name: 'Case'
  states:       ['inactive', 'active']

  components: ember.computed.reads 'settings.ember.components'

  assignment_name:    ember.computed.or    'name', 'default_name'
  first_phase:        ember.computed.reads 'phases.firstObject'
  is_peer_assessment: ember.computed.equal 'bundle_type', 'assessment'
  is_casespace:       ember.computed.equal 'bundle_type', 'casespace'

  # Dates
  is_past_due: ember.computed 'metadata_due_at', -> @get('metadata_due_at') <= Date.now()

  friendly_due_at: ember.computed 'metadata', 'metadata.due_at', ->
    due_at = @get('metadata.due_at')
    return null unless ember.isPresent(due_at)
    due_at = Date.parse(due_at)
    @get('ttz').format(due_at, format: 'MMM Do, h:mm a')

  metadata_due_at: ember.computed 'metadata', 'metadata.due_at', ->
    due_at = @get('metadata.due_at')
    if ember.isPresent(due_at) then Date.parse(due_at) else null

  add_ability: (abilities) ->
    update            = abilities.gradebook
    abilities.update  = update
    abilities.clone   = update
    abilities.destroy = update

  # ### Phase position
  # => Assumes they've been updated via the phase model functions.
  save_phase_positions: ->
    new ember.RSVP.Promise (resolve, reject) =>
      update     = []
      @get(ta.to_p('phases')).then (phases) =>
        phases.forEach (phase) => update.push(phase) if phase.get('isDirty')
        return resolve() if ember.isEmpty(update)
        phase_order = []
        update.forEach (phase) =>
          phase_order.push({phase_id: phase.get('id'), position: phase.get('position')})
        query = 
          action:      'phase_order'
          verb:        'put'
          phase_order: phase_order
          id:          @get('id')
        tc.query(ta.to_p('assignment'), query, payload_type: ta.to_p('phase')).then =>
          resolve()
        , (error) => @error(error)
      , (error) => @error(error)
    , (error) => @error(error)

  # ### Phase helpers
  phase_state_promise: (states) ->
    states  = ember.makeArray(states)
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get(ta.to_p('phases')).then (phases) =>
        filtered = phases.filter (phase) => states.contains(phase.get('state'))
        sorted   = filtered.sortBy('position')
        resolve(sorted)

  phases_without_team_set: ember.computed 'phases.@each.team_category_id', 'phases.@each.team_set_id', ->
    promise  = new ember.RSVP.Promise (resolve, reject) =>
      phases = new Array
      @get(ta.to_p('phases')).then (phases) => 
        filtered = phases.filter (phase) => phase.get('has_team_category_without_team_set')
        resolve(filtered)
    ta.PromiseArray.create promise: promise

  has_phases_without_team_set:    ember.computed.notEmpty 'phases_without_team_set'
  has_no_phases_without_team_set: ember.computed.not 'has_phases_without_team_set'

  # Instructors see both `active` and `inactive` phases in the assignment#show list in the builder.
  # => Therefore, `active_phases` should return the complete set of visible phases. 
  # => Students do not see `inactive` phases due to authorization.
  # => `inactive` is reffered to as "Draft" in the UI.
  has_inactive_phases:    ember.computed.notEmpty 'inactive_phases'
  has_no_inactive_phases: ember.computed.not 'has_inactive_phases'

  inactive_phases:     ember.computed 'phases.@each.state', ->
    ta.PromiseArray.create promise: @phase_state_promise('inactive')

  active_phases: ember.computed 'phases.@each.state', ->
    ta.PromiseArray.create promise: @phase_state_promise(['active', 'inactive'])

  archived_phases: ember.computed 'phases.@each.state', ->
    ta.PromiseArray.create promise: @phase_state_promise('archived')

  # ### Phase validity
  has_valid_phases: ember.computed.and 'has_no_phases_without_team_set', 'has_no_inactive_phases'

  # ### State helpers
  model_state_change: (action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      tc.query(ta.to_p('assignment'), {id: @get('id'), action: action, verb: 'PUT'}, single: true).then (assignment) =>
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  activate:   -> @model_state_change('activate')
  inactivate: -> @model_state_change('inactivate')