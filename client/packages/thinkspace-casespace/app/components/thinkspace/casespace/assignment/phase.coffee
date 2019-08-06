import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  phase_manager: ember.inject.service()
  ttz: ember.inject.service()

  phase_states: ember.computed ->
    if @get('phase_manager').has_active_addon()
      @get('phase_manager.map').get_ownerable_phase_states(@get('model'))
    else
      @get('phase_manager.map').get_current_user_phase_states(@get('model'))

  due_at:     ember.computed.reads 'model.phase_state.metadata.due_at'
  unlock_at:  ember.computed.reads 'model.phase_state.metadata.unlock_at'

  friendly_due_at_date: ember.computed 'due_at', ->
    date = @get('due_at')
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMM D, YYYY', zone: @get('ttz').get_client_zone_iana()

  friendly_due_at_time: ember.computed 'due_at', ->
    date = @get 'due_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'h:mm a', zone: @get('ttz').get_client_zone_iana()

  friendly_unlock_at_date: ember.computed 'unlock_at', ->
    date = @get('unlock_at')
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'MMM D, YYYY', zone: @get('ttz').get_client_zone_iana()

  friendly_unlock_at_time: ember.computed 'unlock_at', ->
    date = @get 'unlock_at'
    return 'N/A' unless ember.isPresent(date)
    @get('ttz').format date, format: 'h:mm a', zone: @get('ttz').get_client_zone_iana()

  friendly_unlock_mode: ember.computed 'mode', ->
    mode = @get('mode')
    switch mode
      when 'date'
        return "on #{@get('friendly_unlock_at_date')} at #{@get('friendly_unlock_at_time')}"
      when 'manual'
        return "manually (currently #{@get('model.phase_state.current_state')})"
      when 'case_release'
        return 'on case release'
      when 'on_previous_phase'
        previous_phase          = @get('previous_phase.phase')
        previous_phase_position = @get('previous_phase.position')
        return "after #{previous_phase_position}. #{previous_phase.get('title')}"

  mode: null

  is_date_mode:             ember.computed.equal 'mode', 'date'
  is_manual_mode:           ember.computed.equal 'mode', 'manual'
  is_case_release_mode:     ember.computed.equal 'mode', 'case_release'
  is_previous_phase_mode:   ember.computed.equal 'mode', 'on_previous_phase'

  r_case_builder_logistics: ns.to_r 'builder', 'cases', 'logistics'

  init: ->
    @_super()
    @init_position().then =>
      @init_previous_phase().then =>
        @init_select_option()

  init_position: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get('position_in_assignment').then (position) =>
        @set('position', position.value)
        resolve()

  init_previous_phase: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      model.get('previous_phase').then (phase) =>
        obj = 
          phase:    null
          position: null

        if ember.isPresent(phase)
          
          obj.phase = phase
          phase.get('position_in_assignment').then (position) =>
            obj.position = position.value if ember.isPresent(position)

        @set('previous_phase', obj) if ember.isPresent(obj)
        ## We also want to know the previous phase's position as per designs
        resolve()

  init_select_option: ->
    model = @get('model')
    previous_phase = @get('previous_phase.phase')
    if model.get('unlock_at')
      @set_mode('date')
    else if model.get('default_state') == 'unlocked'
      @set_mode('case_release')
    else if ember.isPresent(previous_phase) and previous_phase.get('has_unlock_phase')
      @set_mode('on_previous_phase')
    else
      @set_mode('manual')

  set_mode: (mode) -> @set('mode', mode)
  reset_mode:      -> @set('mode', null)
