import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  queryParams: ['message']

  c_user_password_fail: 'thinkspace/common/user/password/fail'

  message: null