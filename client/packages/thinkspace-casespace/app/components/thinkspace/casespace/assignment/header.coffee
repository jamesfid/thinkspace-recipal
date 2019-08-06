import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  r_spaces_show:         ns.to_r 'spaces', 'show'
  r_assignments_reports: ns.to_p 'assignments', 'reports'
  r_assignments_scores:  ns.to_r 'assignments', 'scores'
  r_assignments_show:    ns.to_r 'assignments', 'show'
  r_cm_assessments:      ns.to_r 'case_manager', 'assignments', 'peer_assessment', 'assessments'