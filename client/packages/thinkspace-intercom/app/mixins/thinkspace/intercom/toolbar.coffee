import ember  from 'ember'
import ns     from 'totem/ns'
import config from 'totem/config'

export default ember.Mixin.create
  is_support_visible:     false
  support_button_pressed: false

  # Add the observer to the Support toolbar.
  intercom_show_obs: ember.observer 'is_support_visible', ->
    return if @get('isDestroying') or @get('isDestroyed')
    if $crisp
      if $crisp.is("chat:visible")
        $crisp.push(["do", "chat:hide"])
        $crisp.push(["do", "chat:close"])
      else
        $crisp.push(["do", "chat:show"])
        $crisp.push(["do", "chat:open"])

  # Callbacks
  intercom_chat_closed: ->
    if $crisp
      $crisp.push(["do", "chat:hide"])

  # Bindings
  bind_intercom_events: ->
    if $crisp
      $crisp.push(["on", "chat:closed", @intercom_chat_closed])

  init: ->
    @_super()
    @bind_intercom_events()

