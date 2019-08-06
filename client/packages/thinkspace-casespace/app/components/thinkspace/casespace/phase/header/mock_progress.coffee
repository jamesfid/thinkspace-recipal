import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  r_phases_show: ns.to_r 'phases', 'show'

  is_current_phase: ember.computed -> @get('current_phase') == @get('model')
