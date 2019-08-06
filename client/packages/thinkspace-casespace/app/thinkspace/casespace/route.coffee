import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/base/route'

export default base.extend
  thinkspace:    ember.inject.service()
  casespace:     ember.inject.service()
  phase_manager: ember.inject.service()
  csse:          ember.inject.service ns.to_p('casespace', 'server_events')

  beforeModel: (transition) ->
    thinkspace = @get('thinkspace')
    thinkspace.set_current_transition(transition)  unless thinkspace.transition_is_for(transition, 'case_manager')
    @_super(transition)

  deactivate: ->
    console.warn 'deactivate casespace route'
    @get('casespace').reset_all()
    @get('phase_manager').reset_all()
    @get('csse').reset_all()
