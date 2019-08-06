import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  init: ->
    @_super()
    @set_phase_progress()
    @set_show_components()

  show_components: null

  phase_manager: ember.inject.service()

  totem_data_config: ability: true, metadata: {ajax_source: true}  # require metadata so completed count will be updated after a submit

  c_assignment_header: ns.to_p 'assignment', 'header'
  c_assignment_phases: ns.to_p 'assignment', 'phases'
  c_phase_errors:      ns.to_p 'builder',    'shared', 'phases', 'errors'

  # ### Routes
  r_assignments_edit: ns.to_r 'builder', 'cases', 'overview'
  r_phases_show:      ns.to_r 'phases',  'show'

  all_phases_completed: null
  is_in_progress:       null
  resume_phase:         null
  phase_states_loaded:  false

  set_phase_progress: ->
    assignment = @get('model')
    assignment.get(ns.to_p 'phases' ).then (phases) =>
      phase_promises = phases.getEach(@ns.to_p('phase_states'))
      ember.RSVP.Promise.all(phase_promises).then =>
        sorted_phases = phases.sortBy('position') 
        resume_phase  = sorted_phases.find (phase) -> phase.get('is_unlocked')
        if resume_phase
          @set 'resume_phase', resume_phase
          @set 'is_in_progress', true  if resume_phase != sorted_phases.get('firstObject')
        uncompleted_phase = phases.find (phase) -> phase.get('is_completed') != true
        @set 'all_phases_completed', true unless uncompleted_phase
        @set 'phase_states_loaded', true
      , (error) =>
        @totem_messages.api_failure error, source: @, model: ns.to_p('phase_states')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: ns.to_p('phases')

  set_show_components: ->
    paths = @get('model.components.show')
    return unless paths
    comps = ember.makeArray(paths).map (path) -> ns.to_p(path)
    @set 'show_components', comps

  actions:
    activate: ->
      @totem_messages.show_loading_outlet()
      @get('model').activate().then =>
        @totem_messages.hide_loading_outlet()

    inactivate: ->
      @totem_messages.show_loading_outlet()
      @get('model').inactivate().then =>
        @totem_messages.hide_loading_outlet()
