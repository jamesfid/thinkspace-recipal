import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/component'

export default base.extend

  state_buttons: [
    {id: 'lock',     label: 'Locked'}
    {id: 'unlock',   label: 'Unlocked'}
    {id: 'complete', label: 'Completed'}
  ]

  init: ->
    @_super()
    @validate = @rad.validate

  actions:
    select: (state) ->
      @set 'selected_state', state
      @rad.set_phase_state(state)
      @sendAction 'validate' if @validate
