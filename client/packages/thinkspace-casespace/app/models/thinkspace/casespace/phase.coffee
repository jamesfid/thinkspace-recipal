import ember          from 'ember'
import ta             from 'totem/ds/associations'
import tc             from 'totem/cache'
import resource_mixin from 'thinkspace-resource/mixins/resources'

export default ta.Model.extend ta.totem_data, resource_mixin, ta.add(
    ta.belongs_to 'assignment',        reads: {}
    ta.belongs_to 'configuration',     reads: {}
    ta.belongs_to 'phase_template',    reads: {}
    ta.has_many   'phase_components',  reads: {}
    ta.has_many   'phase_states',      reads: {filter: true, notify: true}
  ), 

  title:            ta.attr('string')
  team_category_id: ta.attr('number')
  team_set_id:      ta.attr('number')
  active:           ta.attr('boolean')
  team_ownerable:   ta.attr('boolean')
  position:         ta.attr('number')
  description:      ta.attr('string')
  user_action:      ta.attr('string')
  default_state:    ta.attr('string')
  state:            ta.attr('string')
  unlock_at:        ta.attr('date')
  due_at:           ta.attr('date')
  settings:         ta.attr()

  totem_data_config: ability: true

  ttz: ember.inject.service()

  didLoad: ->
    @get(ta.to_p 'assignment').then (assignment) =>
      assignment.get(ta.to_p 'phases').then (phases) =>
        phases.pushObject(@) unless phases.contains(@)

  is_team_ownerable: -> @get('team_ownerable')

  # Phase Configuration.
  configuration_validate: ember.computed.reads 'settings.validation.validate'
  max_score:              ember.computed.reads 'settings.phase_score_validation.numericality.less_than_or_equal_to'
  submit_text:            ember.computed.reads 'settings.submit.text'
  show_errors_on_submit:  ember.computed.reads 'settings.submit.show_errors'
  submit_visible:         ember.computed.reads 'settings.submit.visible'
  is_submit_visible:      ember.computed.bool  'submit_visible'

  has_auto_score:                     ember.computed.reads 'settings.actions.submit.auto_score'
  has_unlock_phase:                   ember.computed.equal 'settings.actions.submit.unlock', 'next'
  has_complete_phase:                 ember.computed.equal 'settings.actions.submit.state', 'complete'
  has_team_category:                  ember.computed.notEmpty 'team_category_id'
  has_team_set:                       ember.computed.notEmpty 'team_set_id'
  has_team_category_without_team_set: ember.computed 'has_team_category', 'has_team_set', -> @get('has_team_category') and !@get('has_team_set')

  # Phase states.
  phase_state:     ember.computed.reads 'phase_states.firstObject' 
  current_state:   ember.computed.or    'phase_state.current_state', 'default_state'
  is_unlocked:     ember.computed.bool  'phase_state.is_unlocked'
  is_locked:       ember.computed.bool  'phase_state.is_locked'
  is_active:       ember.computed.equal 'state', 'active'
  is_inactive:     ember.computed.equal 'state', 'inactive'
  is_archived:     ember.computed.equal 'state', 'archived'
  is_not_active:   ember.computed.not   'is_active'
  is_not_archived: ember.computed.not   'is_archived'

  # Date display.
  friendly_unlock_at_date: ember.computed 'unlock_at', ->
    date = @get 'unlock_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMM D, YYYY', zone: @get('ttz').get_client_zone_iana()

  friendly_unlock_at_time: ember.computed 'unlock_at', ->
    date = @get 'unlock_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'h:mm a', zone: @get('ttz').get_client_zone_iana()

  friendly_unlock_at_date_and_time: ember.computed 'unlock_at', ->
    @get('friendly_unlock_at_date') + ' at ' + @get('friendly_unlock_at_time')

  friendly_due_at_date: ember.computed 'due_at', ->
    date = @get 'due_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMM D, YYYY', zone: @get('ttz').get_client_zone_iana()

  friendly_due_at_time: ember.computed 'due_at', ->
    date = @get 'due_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'h:mm a', zone: @get('ttz').get_client_zone_iana()

  friendly_due_at_date_and_time: ember.computed 'due_at', ->
    @get('friendly_due_at_date') + ' at ' + @get('friendly_due_at_time')

  unlock_mode: ember.computed 'default_state', 'unlock_at', 'position', 'previous_phase.settings.actions.submit.unlock', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get_unlock_mode().then (unlock_mode) => 
        resolve unlock_mode
    ta.PromiseObject.create promise: promise

  unlock_mode_display: ember.computed 'default_state', 'unlock_at', 'position', 'previous_phase.settings.actions.submit.unlock', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get_unlock_mode_display().then (unlock_mode_display) => 
        resolve unlock_mode_display
    ta.PromiseObject.create promise: promise

  # Unlock mode helpers.
  get_unlock_mode: -> 
    new ember.RSVP.Promise (resolve, reject) =>
      @get('previous_phase').then (phase) =>
        if @get('unlock_at')
          resolve 'date'
        else if @get('default_state') == 'unlocked'
          resolve 'case release'
        else if ember.isPresent(phase) and phase.get('has_unlock_phase')
          resolve 'previous phase submission'
        else
          resolve 'manual'

  get_unlock_mode_display: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_unlock_mode().then (unlock_mode) =>
        switch unlock_mode
          when 'date'
            date = moment(@get('unlock_at')).format('MMM D, YYYY')
            time = moment(@get('unlock_at')).format('h:mm a')
            resolve "Unlocks on #{@get('friendly_unlock_at_date_and_time')}"
          when 'case release'
            resolve 'Unlocks on case release'
          when 'previous phase submission'
            @get('previous_phase').then (phase) =>
              phase.get('position_in_assignment').then (position) =>
                resolve "Unlocks after #{position.value}. #{phase.get('title')}"
          when 'manual'
            resolve "Unlocks manually (currently locked)"

  # Previous/Next Phases.
  previous_phase: ember.computed ta.to_p('assignment'), ta.to_prop('assignment', 'phases', 'length'), 'position', -> @get_phase_at_index_increment(-1)
  next_phase:     ember.computed ta.to_p('assignment'), ta.to_prop('assignment', 'phases', 'length'), 'position', -> @get_phase_at_index_increment(+1)

  get_phase_at_index_increment: (increment) ->
    promise = new ember.RSVP.Promise (resolve, reject) => 
      @get(ta.to_p 'assignment').then (assignment) =>
        assignment.get('active_phases').then (phases) =>
          index     = phases.indexOf(@)
          new_index = index + increment
          phase     = phases.objectAt(new_index)
          return resolve(null) unless ember.isPresent(phase)
          resolve phase
        , (error) => reject(error)
      , (error) => reject(error)
    ta.PromiseObject.create promise: promise

  # Should friendly here be 'defaulted' or something as a convention?
  # => Friendly would usually mean something like '2014-09-01 12:01:00Z' to 'Aug. 1st 2014'
  friendly_submit_visible: ember.computed 'submit_visible', -> ( @get('submit_visible')? and @get('submit_visible') ) or true
  friendly_submit_text:    ember.computed 'submit_text',    -> @get('submit_text') or 'Submit'
  friendly_max_score:      ember.computed 'max_score',      -> (@get('max_score')? and parseInt(@get('max_score'))) or 1

  # ### Movement helpers
  # => Note, these do not save the movement positions, only set them client side.
  move_to_top: ->
    @get_sorted_phases().then (phases) =>
      phases.removeObject(@)
      phases.insertAt 0, @
      phases.forEach (phase, index) => 
        position = phase.get('position')
        phase.set 'position', index
        phase.notifyPropertyChange 'position' if position == index # For updating unlock_mode text that relies on the previous phase's settings


  move_to_bottom: ->
    @get_sorted_phases().then (phases) =>
      phases.removeObject(@)
      length = phases.get('length')
      phases.insertAt length, @
      phases.forEach (phase, index) => 
        position = phase.get('position')
        phase.set 'position', index
        phase.notifyPropertyChange 'position' if position == index

  move_to_offset: (offset) ->
    @get_sorted_phases().then (phases) =>
        index     = phases.indexOf(@)
        new_index = index + offset
        length    = phases.get('length')
        return if new_index >= length or new_index < 0
        phases.removeObject @
        phases.insertAt new_index, @
        phases.forEach (phase, index) => 
          position = phase.get('position')
          phase.set 'position', index
          phase.notifyPropertyChange 'position' if position == index

  get_sorted_phases: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get(ta.to_p('assignment')).then (assignment) =>
        if @get('is_active') then property = 'active_phases' else property = 'archived_phases'
        assignment.get(property).then (phases) =>
          sorted    = phases.sortBy('position')
          resolve(sorted)

  # ### Position helpers
  # => If the `position` gets off, the UI will still represent it correctly.
  position_in_assignment: ember.computed 'position', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      if @get('is_archived')
        resolve {value: @get('position')}
      else
        @get(ta.to_p('assignment')).then (assignment) =>
          assignment.get('active_phases').then (phases) =>
            position = phases.indexOf(@)
            return resolve({value: 0}) unless ember.isPresent(position)
            resolve {value: position + 1} # Add one since it's a count not an index.
    ta.PromiseObject.create promise: promise

  # ### State helpers
  state_change: (action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      tc.query(ta.to_p('phase'), {id: @get('id'), action: action, verb: 'PUT'}, single: true).then (phase) =>
        resolve(phase)
      , (error) => @error(error)
    , (error) => @error(error)

  inactivate: -> @state_change('inactivate')
  archive:    -> @state_change('archive')
  activate:   -> @state_change('activate')