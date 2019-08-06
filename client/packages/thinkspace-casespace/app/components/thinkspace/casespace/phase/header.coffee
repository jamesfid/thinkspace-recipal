import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  phase_manager: ember.inject.service()

  r_phases_show:      ns.to_r 'phases', 'show'
  r_phases_edit:      ns.to_r 'builder', 'phases', 'edit'
  r_spaces_show:      ns.to_r 'spaces', 'show'
  r_assignments_show: ns.to_r 'assignments', 'show'

  c_select_phase_state:  ns.to_p 'phase', 'select_phase_state'
  c_progress:            ns.to_p 'phase', 'header', 'progress'
  c_mock_progress:       ns.to_p 'phase', 'header', 'mock_progress'
  t_collaboration_teams: ns.to_t 'phase', 'header', 'collaboration_teams'

  actions:
    select_phase_state: (phase_state) ->
      # When the header component is used outside of a phase template (e.g. select a team) and the phase 'show'
      # template is not displayed, send the action rather than re-generating the phase show view.
      if @get('select_send_action')
        @sendAction 'select_send_action', phase_state
      else
        phase_manager = @get('phase_manager')
        @get('phase_manager').set_ownerable_from_phase_state(phase_state).then => phase_manager.generate_view_with_ownerable()
