import ember from 'ember'
import base  from 'thinkspace-casespace-case-manager/routes/base'
import ns from 'totem/ns'

export default base.extend
  model: -> @modelFor ns.to_p 'case_manager', 'assignments', 'peer_assessment'