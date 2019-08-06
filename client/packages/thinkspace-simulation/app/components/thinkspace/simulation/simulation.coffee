import ember from 'ember'
import ds from 'ember-data'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['ts-componentable']
  
  # ### Properties
  component_path: null

  # ### Components
  c_simulation: ember.computed ->
    ns.to_p('simulation', 'simulations', @get('model.path'))

