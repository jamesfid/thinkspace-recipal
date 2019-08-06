import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-casespace-case-manager/components/wizards/steps/base'

export default base.extend

  actions:
    # Using 'debounce' to make moves more naturally responsive for rapid clicks.
    move_up:     (phase) -> ember.run.debounce(@, @move_phase, phase, 'up',     200)
    move_down:   (phase) -> ember.run.debounce(@, @move_phase, phase, 'down',   200)
    move_top:    (phase) -> ember.run.debounce(@, @move_phase, phase, 'top',    200)
    move_bottom: (phase) -> ember.run.debounce(@, @move_phase, phase, 'bottom', 200)

    save: ->
      @save_phase_positions()
      @send 'exit'

    cancel: ->
      @rollback_phases()
      @send 'exit'

    exit: ->
      wizard_manager = @get('wizard_manager')
      assignment     = @get('model')
      wizard_manager.transition_to_assignment_edit assignment, queryParams: { step: 'phases' }

  save_phase_positions: ->
    update     = []
    assignment = @get('model')
    phases     = assignment.get('phases')
    store      = assignment.store
    phases.forEach (phase) =>
      update.push(phase) if phase.get('isDirty')
    return if update.get('length') < 1
    return unless ember.isPresent(assignment)
    phase_order = []
    update.forEach (phase) =>
      phase_order.push({phase_id: phase.get('id'), position: phase.get('position')})
    query =
      model:  assignment
      action: 'phase_order'
      verb:   'put'
      data:   
        phase_order: phase_order
      id: assignment.get('id')
    ajax.object(query).then (payload) =>
      type       = ns.to_p('phase')
      records    = payload[ns.to_p('phases')]
      normalized = records.map (record) => store.normalize(type, record)
      records    = store.pushMany(type, normalized)
      records

  move_phase: (phase, direction) ->
    switch direction
      when 'up'
        @swap_phase_positions(phase, -1)
      when 'down'
        @swap_phase_positions(phase, +1)
      when 'top'
        @move_to_top(phase)
      when 'bottom'
        @move_to_bottom(phase)
      else
        return

  rollback_phases: ->
    phases = @get('model.phases')
    phases.forEach (phase) =>
      phase.rollback()  if phase.get('isDirty')

  swap_phase_positions: (phase, inc) ->
    phases = @get('model.phases')
    index  = phases.indexOf(phase)
    return unless index >= 0  # phase not found
    index += inc
    return if index < 0  # move up and already at top e.g. no phases before current phase
    other = phases.objectAt(index)
    return unless other # move down but already at bottom e.g. no phases after current phase
    other_pos = other.get('position')
    phase_pos = phase.get('position')
    other.set 'position', phase_pos
    phase.set 'position', other_pos

  # Move top and bottom uses the phase 'association' array.  Otherwise during the forEach the
  # sorted array is altered after each set 'position' and results in altering the phases' indexes.
  move_to_top: (phase) ->
    phases      = @get('model.phases').sortBy('position')
    phase_index = phases.indexOf(phase)
    return unless phase_index?
    running_pos = 1
    phase.set 'position', running_pos
    phases.forEach (other, index) =>
      other.set('position', running_pos += 1)  unless index == phase_index

  move_to_bottom: (phase) ->
    phases      = @get('model.phases').sortBy('position')
    phase_index = phases.indexOf(phase)
    return unless phase_index?
    running_pos = 0
    phase.set 'position', phases.get('length')
    phases.forEach (other, index) =>
      other.set('position', running_pos += 1)  unless index == phase_index
