import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  domain_phase_states: [
    {state: 'unlocked',  title: 'Unlocked', description: 'The learner can access the phase and modify their responses.'},
    {state: 'locked',    title: 'Locked', description: 'The learner cannot access this phase at all.'},
    {state: 'completed', title: 'Completed', description: 'The learner can view the phase, but not modify any responses.'}
  ]

  actions:
    change: (state) -> @sendAction 'change', state