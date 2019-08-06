import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend

  c_user_password_show: 'thinkspace/common/user/password/show'

  actions:

    goto_users_password_success: ->
      @transitionToRoute 'users/password.success'

    goto_users_password_fail: (error) ->
      message = error.responseJSON.errors.user_message
      @transitionToRoute 'users/password.fail', queryParams: { message: message }