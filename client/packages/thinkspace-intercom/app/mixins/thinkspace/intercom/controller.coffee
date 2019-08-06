import ember  from 'ember'
import config from 'totem/config'

export default ember.Mixin.create

  # Add application controller observer.
  intercom_boot_obs: (->
    # By default, hide the chat bubble.
    $crisp.push(["do", "chat:hide"]) if $crisp
    user = @get('session.user')
    return if ember.isBlank($crisp) or ember.isBlank(user)
    $crisp.push(["set", "user:email", user.get('email')])
    $crisp.push(["set", "user:nickname", user.get('full_name')])
  ).observes('session.user').on('init')
