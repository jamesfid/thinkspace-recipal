import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base  from 'thinkspace-builder/components/wizard/steps/base'

export default base.extend
  # ### Properties
  title:               ember.computed.reads 'builder.model.title'
  archived_phases:     null
  active_phases:       null
  
  is_ordering:         false
  is_viewing_archived: false
  is_adding_phase:     false

  # ### Components
  c_phase:        ns.to_p 'builder', 'steps',  'parts',  'phases', 'phase'
  c_new_phase:    ns.to_p 'builder', 'steps',  'parts',  'phases', 'new'
  c_phase_errors: ns.to_p 'builder', 'shared', 'phases', 'errors'

  # ### Events
  init: ->
    @_super()
    @load_assignment().then => @set_all_data_loaded()

  # ### Helpers
  load_assignment: ->
    # May double load if refreshing page, but ensures that assignment is loaded (e.g. coming from templates phase).
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.get(ns.to_p('phases')).then (phases) =>
        return resolve() if phases.get('length') > 0
        @tc.query(ns.to_p('assignment'), {id: model.get('id'), action: 'load'}, single: true).then (assignment) =>
          resolve()

  actions:
    toggle_is_ordering:         -> @toggleProperty 'is_ordering'
    toggle_is_viewing_archived: -> @toggleProperty 'is_viewing_archived'
    toggle_is_adding_phase:     -> @toggleProperty 'is_adding_phase'
    reset_is_adding_phase:      -> @set 'is_adding_phase', false

    cancel_ordering: ->
      model = @get 'model'
      model.get(ns.to_p('phases')).then (phases) =>
        phases.forEach (phase) => phase.rollback() if phase.get('isDirty')
        @set 'is_ordering', false

    save_order: ->
      model = @get 'model'
      @totem_messages.show_loading_outlet()
      model.save_phase_positions().then =>
        @totem_messages.hide_loading_outlet()
        @set 'is_ordering', false
