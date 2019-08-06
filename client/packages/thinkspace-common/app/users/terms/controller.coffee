import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  # ### Properties
  tos: null # Agreement

  # ### Components
  c_user_terms: ns.to_p('user', 'terms')