import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend

  c_user_password_new: 'thinkspace/common/user/password/new'

  actions:

    goto_users_password_confirmation: ->
      @transitionToRoute 'users/password.confirmation'