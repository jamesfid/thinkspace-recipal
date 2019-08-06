import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend

  c_user_show_profile: ns.to_p('user', 'show', 'profile')

  actions:
    update_password: ->
      @transitionToRoute 'users/password.new'