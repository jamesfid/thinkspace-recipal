import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/components/wizards/steps/base'

export default base.extend
  # ### Properties
  step:       'phases'
  is_adding:  false
  page_title: ember.computed.reads 'model.title'

  # ### Components
  c_phase_clone:   ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', 'phases', 'clone'
  c_phase:         ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace', 'steps', 'phases', 'phase'

  # ### Routes
  r_phase_order: ns.to_r 'case_manager', 'assignments', 'phase_order'

  actions:
    reset_is_adding: -> @set 'is_adding', false
    set_is_adding:   -> @set 'is_adding', true
