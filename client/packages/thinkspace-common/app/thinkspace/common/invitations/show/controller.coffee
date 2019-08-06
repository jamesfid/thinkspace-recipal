import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  queryParams: ['email']

  c_new_user:  ns.to_p 'user', 'new'
  email:       null