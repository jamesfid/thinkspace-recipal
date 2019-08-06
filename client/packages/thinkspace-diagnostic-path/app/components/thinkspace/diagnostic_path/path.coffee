import ember from 'ember'
import ns    from 'totem/ns'
import path_manager from 'thinkspace-diagnostic-path/path_manager'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames:    ['ts-componentable', 'diag-path_']

  # ### Properties
  all_collapsed:      false
  edit_visible:       false
  is_view_only:       ember.computed.reads 'totem_scope.is_view_only'
  ownerable_children: ember.computed -> @get('tvo.helper').ownerable_view_association_promise_array(@, association: 'children', ready: true)

  scoped_children: ember.computed 'ownerable_children.@each', ->
    records = @get 'ownerable_children'
    records.filter (record) =>
      type   = record.get 'ownerable_type'
      type   = @totem_scope.standard_record_path(type)
      id     = record.get 'ownerable_id'
      o_type = @totem_scope.get_ownerable_type()
      o_id   = @totem_scope.get_ownerable_id()
      ember.isEqual(type, o_type) and ember.isEqual(id, o_id)

  # ### Components
  c_path_edit:      ns.to_p 'diagnostic_path', 'path', 'edit'
  c_path_item:      ns.to_p 'diagnostic_path', 'path_item', 'show'
  c_path_mechanism: ns.to_p 'diagnostic_path', 'path_item', 'mechanism'

  # ### Services
  tvo: ember.inject.service()

  # ### Observers
  ownerable_children_observer: ember.observer 'ownerable_children.isFulfilled', ->
    path     = @get 'model'
    children = path.get(ns.to_p('path_items')).then (path_items) =>
      length = path_items.get('length')
      @add_default_mechanism() if length == 0

  # ### Events
  init: ->
    @_super()
    @get('tvo.helper').define_ready(@)
    @get('tvo.status').register_validation('diagnostic_path', @, 'validate_diagnostic_path')

  didInsertElement: ->
    @_super()
    return if @get('is_view_only')
    @$('.diag-path_list').sortable
      group:   'path-obs-list'
      clone:   true
      consume: true
      exclude: '.sortable-exclude'
      component: @
      # root_selector: '.diag-path_'
      # item_selector: '.diag-path_list-item'

    @$('.diag-path_mechanism-list').sortable
      group:           'path-obs-list'
      clone:           true
      consume:         true
      exclude:         '.sortable-exclude'
      component:       @
      drop:            false

  willDestroyElement: ->
    @$('.diag-path_list').sortable('destroy')
    @$('.diag-path_mechanism-list').sortable('destroy')

  # ### Helpers
  add_default_mechanism: ->
    event = @get_root_mock_event(@get_root_last_path_item())
    @dragend_new_mechanism(event)

  # jquery-sortable helpers
  get_root_list:           -> @$('.diag-path_list').first()
  get_root_last_path_item: -> @get_root_list().children('.diag-path_list-item').last()
  get_root_mock_event: (prev_item) -> 
    event =
      dropped_container:
        el:       @get_root_list()
        prevItem: prev_item

  # Generic dragend event called from a non-diagnostic-path_item component (e.g. observation-list observation).
  # Arguments are the dragend-event, the record type and the record id (to populate the path_itemable).
  dragend_process: (event, type, id) ->
    path = @get('model')
    @set_is_saving()
    path_manager.dragend_new_diagnostic_path_item(path, event, type, id).then =>
      @reset_is_saving()

  # Called by the path-item component to move the path items.
  dragend_move_diagnostic_path_items: (event) ->
    path = @get('model')
    @set_is_saving()
    path_manager.dragend_move_diagnostic_path_items(path, event).then =>
      @reset_is_saving()

  # Called by the mechanism component to add one.
  dragend_new_mechanism: (event) ->
    path = @get('model')
    @set_is_saving()
    path_manager.dragend_new_mechanism_path_item(path, event, 'New mechanism').then =>
      @reset_is_saving()

  set_is_saving: ->
    @set('is_saving', true)
    @totem_messages.show_loading_outlet(message: 'Updating path...')

  reset_is_saving: ->
    @set('is_saving', false)
    @totem_messages.hide_loading_outlet()

  # ###
  # ### Submit Validation.
  # ###

  validate_diagnostic_path: (status) ->
    new ember.RSVP.Promise (resolve, reject) =>
      tvo      = @get('tvo')
      section  = @get('attributes.source')
      action   = 'itemables'
      messages = []
      status.set_is_valid(true)
      if tvo.section.has_action(section, action)
        tvo.section.call_action(section, action).then (itemables) =>
          itemables.forEach (item) =>
            unless item.get_is_used() == true
              status.increment_invalid_count()
              status.set_is_valid(false)
              # messages.push "Not used: #{item.get('value')}"
          messages.push "Use all observations."  unless status.get_is_valid()
          status.set_status_messages messages.uniq()
          resolve()
        , (error) => reject(error)
    , (error) => reject(error)

  
  actions:
    add_mechanism_bottom: -> @add_default_mechanism()

    toggle_collapse_all: ->
      @toggleProperty('all_collapsed')
      return

    edit: -> @set('edit_visible', true)

    save: ->
      path = @get('model')
      @set('edit_visible', false)    
      return unless path.get('isDirty')
      path.save().then (path) =>
        @totem_messages.api_success source: @, model: path, action: 'save', i18n_path: ns.to_o('path', 'save')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: path, action: 'save'