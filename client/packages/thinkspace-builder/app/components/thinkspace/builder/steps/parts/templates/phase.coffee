import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  model:                   null
  selected_phase_template: null

  # ### Computed properties
  is_selected: ember.computed 'model', 'selected_phase', ->
    model          = @get 'model'
    selected_phase = @get 'selected_phase'
    ember.isEqual(model, selected_phase)

  # ### Events
  init: ->
    @_super()
    model = @get 'model'
    model.get(ns.to_p('phase_template')).then (phase_template) =>
      @set 'phase_template', phase_template
      @set_all_data_loaded()

  actions:
    select: ->
      @sendAction 'select', @get 'model'