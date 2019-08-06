import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  casespace:     ember.inject.service()
  phase_manager: ember.inject.service()
  #pubsub:        ember.inject.service()
  messages:      ember.inject.service ns.to_p('casespace', 'messages')

  init: ->
    @_super()
    @is_active = ember.isPresent(window.io)
    if @is_active
      @store     = @get_store()
      @casespace = @get('casespace')
      @pm        = @get('phase_manager')
      @pubsub    = null
      @messages  = @get('messages')

  reset_all: -> @leave_all()

  toString: -> 'CasespaceServerEvents'
