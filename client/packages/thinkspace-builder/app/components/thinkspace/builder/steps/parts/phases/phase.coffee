import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  model:       null
  is_ordering: null
  assignment:  null
  tagName:     ''

  dropdown_collection: ember.computed 'model.state', ->
    collection = []
    collection.pushObject {display: 'Clone', action: 'clone'}
    collection.pushObject {display: 'Archive', action: 'archive'}   if @get('model.is_not_archived')
    collection.pushObject {display: 'Activate', action: 'activate'} if @get('model.is_not_active') and @get('model.is_not_archived')
    collection.pushObject {display: 'Save as Draft', action: 'inactivate'} if @get('model.is_active') or @get('model.is_archived')
    collection.pushObject {display: 'Delete', action: 'delete'}
    collection

  # ### Routes
  r_phases_edit: ns.to_r 'builder', 'phases', 'edit'

  # ### Components
  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'

  # ### Helpers
  model_state_change: (action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      return unless ember.isPresent(model)
      @totem_messages.show_loading_outlet()
      return unless model[action]?
      model[action]().then (phase) =>
        @totem_messages.hide_loading_outlet()
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  actions:
    activate:   -> @model_state_change('activate')
    archive:    -> @model_state_change('archive')
    inactivate: -> @model_state_change('inactivate')

    clone: ->
      model = @get 'model'
      @totem_messages.show_loading_outlet message: "Cloning #{model.get('title')}..."
      model.get(ns.to_p('assignment')).then (assignment) =>
        data = 
          phase_id:      model.get 'id'
          assignment_id: assignment.get 'id'
          verb:          'POST'
          action:        'clone'
        @tc.query(ns.to_p('phase'), data, single: true).then (phase) =>
          @totem_messages.hide_loading_outlet()
          @totem_messages.api_success source: @, model: phase, action: 'clone', i18n_path: ns.to_o('phase', 'clone')
        , (error) =>
          @totem_messages.hide_loading_outlet()
          @totem_messages.api_failure error, source: @, model: model, action: 'clone'    
      , (error) => 
        @totem_messages.hide_loading_outlet()
        @totem_messages.api_failure error, source: @, model: model, action: 'clone'

    delete: ->
      confirm = window.confirm('Are you sure you want to delete this phase?')
      return unless confirm
      phase = @get 'model'
      phase.deleteRecord()
      phase.save().then =>
        @totem_messages.api_success source: @, model: phase, action: 'destroy', i18n_path: ns.to_o('phase', 'destroy')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: phase, action: 'destroy'

    move_up:        -> @get('model').move_to_offset(-1)
    move_down:      -> @get('model').move_to_offset(1)
    move_to_top:    -> @get('model').move_to_top()
    move_to_bottom: -> @get('model').move_to_bottom()