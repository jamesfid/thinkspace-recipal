import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  c_assignment:      ns.to_p 'assignment'
  c_loader:          ns.to_p 'common', 'loader'
  r_assignments_new: ns.to_r 'builder', 'cases', 'new'

  init: ->
    @_super()
    model = @get 'model'
    model.get(ns.to_p('assignments')).then (assignments) =>
      @set_all_data_loaded()
