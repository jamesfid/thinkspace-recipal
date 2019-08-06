import ember          from 'ember'
import ns             from 'totem/ns'
import totem_error    from 'totem/error'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  manager: ember.inject.service(ns.to_p 'readiness_assurance', 'admin_manager')

  init: ->
    @_super()
    @am            = @get('manager')
    @ready         = false
    @selected_send = false

  get_ready:     -> @get 'ready'
  set_ready_on:  -> @set 'ready', true
  set_ready_off: -> @set 'ready', false

  selected_send_on:  -> @set 'selected_send', true
  selected_send_off: -> @set 'selected_send', false

  sort_users: (users) ->
    return [] if ember.isBlank(users)
    user.name = @get_username(user) for user in users
    users.sortBy 'name'

  get_username: (user) -> "#{user.last_name}, #{user.first_name}"

  error: (args...) ->
    message = args.shift() or ''
    console.error message, args if ember.isPresent(args)
    totem_error.throw @, message
