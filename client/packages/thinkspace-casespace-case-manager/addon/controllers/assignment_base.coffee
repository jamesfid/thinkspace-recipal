import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/controllers/base'

export default base.extend

  queryParams: ['bundle_type', 'step', 'space_id']
  bundle_type: 'selector'  # Default
  step:        null        # Default 
  space_id:    null

  # Components
  c_assignment_wizard: ns.to_p 'case_manager', 'assignment', 'wizard'
  c_wizard:            ns.to_p 'case_manager', 'assignment', 'wizards', 'casespace'

  # ### Helpers
  reset_query_params: ->
    # space_id set by query_params in link-to, does not need to be cleared.  
    # => Step will persist from other sessions if not cleared.
    @set 'step', null

  actions:
    set_bundle_type: (bundle_type) -> @set('bundle_type', bundle_type)
    set_step:        (step) -> @set('step', step)
