import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  tagName: ''

  # ### Computed properties
  is_selected: ember.computed 'builder.step', ->
    builder_step = @get 'builder.step'
    step         = @get 'model'
    ember.isEqual(builder_step, step)

  is_completed: ember.computed.reads 'model.is_completed'

  actions:
    select: ->
      builder = @get 'builder'
      step    = @get 'model'
      builder.set_current_step_and_transition step