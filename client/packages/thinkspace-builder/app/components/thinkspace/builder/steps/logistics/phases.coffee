import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'ul'

  c_logistics_phase: ns.to_p 'builder', 'steps', 'logistics', 'phase'
  c_loader:          ns.to_p 'common', 'loader'

  init: ->
    @_super()
    @set_all_data_loaded()

  bulk_reset_date: (property) ->
    @reset_all_data_loaded()
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      ids   = model.getEach('id')

      query =
        action:   'bulk_reset_date'
        verb:     'POST'
        ids:      ids
        property: property

      @tc.query(ns.to_p('phase'), query).then (phases) =>
        @set_all_data_loaded()
        resolve phases

  actions: 

    select_unlock_at: (date) -> @sendAction 'select_unlock_at', date

    register_phase: (component) ->
      @sendAction 'register_phase', component

    reset_unlock_at: -> @bulk_reset_date('unlock_at')
    reset_due_at:    -> @bulk_reset_date('due_at')

