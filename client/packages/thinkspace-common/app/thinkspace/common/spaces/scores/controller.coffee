import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  # ### Components
  c_gradebook_assignment:   ns.to_p 'gradebook', 'assignment'
  c_gradebook_phase:        ns.to_p 'gradebook', 'phase'