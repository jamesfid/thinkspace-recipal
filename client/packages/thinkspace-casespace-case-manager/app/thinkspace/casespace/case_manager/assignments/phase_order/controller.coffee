import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/controllers/assignment_base'

export default base.extend

  c_phase_order: ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', 'phases', 'order'
