import ember from 'ember'
import totem_scope from 'totem/scope'
import ns from 'totem/ns'

export default ember.Controller.extend
  queryParams: ['invitable', 'email', 'refer']

  invitable: null
  email:     null
  refer:     null

  # Components
  c_user_sign_in: ns.to_p 'common', 'user', 'sign_in'