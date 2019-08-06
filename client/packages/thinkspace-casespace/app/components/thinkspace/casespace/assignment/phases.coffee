import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  r_phases_show:      ns.to_r 'phases', 'show'
  c_assignment_phase: ns.to_p 'assignment', 'phase'

  actions:
    toggle_details: -> 
      @toggleProperty('display_phase_details')