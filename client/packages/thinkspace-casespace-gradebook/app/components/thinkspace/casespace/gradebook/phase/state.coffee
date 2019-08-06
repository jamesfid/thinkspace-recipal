import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  layoutName: ns.to_t('gradebook', 'phase/state')

  domain_phase_states: [
    {state: 'unlocked',  title: 'Unlock'},
    {state: 'locked',    title: 'Lock'},
    {state: 'completed', title: 'Complete'},
  ]

  actions:
    change: (state) -> @sendAction 'change', state