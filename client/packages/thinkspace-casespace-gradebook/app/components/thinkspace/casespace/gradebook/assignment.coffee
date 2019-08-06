import ember          from 'ember'
import ns             from 'totem/ns'
import totem_scope    from 'totem/scope'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  casespace:           ember.inject.service()

  current_assignment: ember.computed.reads 'casespace.current_assignment'

  selected_assignment: null
  selected_phase:      null

  t_header:        ns.to_t 'gradebook', 'assignment', 'header'
  t_select_scores: ns.to_t 'gradebook', 'assignment', 'select_scores'
  t_show_scores:   ns.to_t 'gradebook', 'assignment', 'show_scores'
  t_footer:        ns.to_t 'gradebook', 'assignment', 'footer'

  c_roster_assignment_scores: ns.to_p 'gradebook', 'assignment', 'roster', 'assignment', 'scores'
  c_roster_phase_scores:      ns.to_p 'gradebook', 'assignment', 'roster', 'phase', 'scores'

  # Prompt text.
  select_phase_scores_prompt:      'View Phase Scores'
  select_assignment_scores_prompt: 'View Assignment Scores'
  select_phase_scores_visible:     false

  assignment_scores_visible:                   false
  phase_scores_visible:                        false
  show_scores:                                 ember.computed.or 'assignment_scores_visible', 'phase_scores_visible'
  phase_scores_or_select_phase_scores_visible: ember.computed.or 'phase_scores_visible', 'select_phase_scores_visible'

  # ### Events
  willInsertElement: -> @send 'select_assignment_scores'

  actions:
    select_assignment_scores: ->
      @set 'selected_phase', null
      @set 'phase_scores_visible', false
      @set 'select_phase_scores_visible', false
      @set 'selected_assignment', @get 'current_assignment'
      @set 'assignment_scores_visible', true

    select_phase_scores: (phase) ->
      @set 'selected_assignment', null
      @set 'assignment_scores_visible', false
      @set 'selected_phase', phase
      @set 'phase_scores_visible', true

    toggle_select_phase_scores: ->
      @toggleProperty 'select_phase_scores_visible'
      @set 'assignment_scores_visible', false
      false

    view_phase_list: ->
      @set 'select_phase_scores_visible', true
      @set 'phase_scores_visible', false
      @set 'selected_phase', null

    close: ->
      @set 'selected_assignment', null
      @set 'selected_phase', null
      @set 'select_assignment_scores_visible', false
      @set 'select_phase_scores_visible', false
      @set 'assignment_scores_visible', false
      @set 'phase_scores_visible', false