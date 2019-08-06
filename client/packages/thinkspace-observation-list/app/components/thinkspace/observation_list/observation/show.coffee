import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName:           'li'

  classNames:        ['obs-list_list-item', 'gu-draggable']
  classNameBindings: ['draggable_class']
  attributeBindings: ['model_id', 'model_type', 'model_value_path']
  model_id:          ember.computed -> @get('model.id')
  model_type:        ember.computed -> @totem_scope.get_record_path @get('model')
  model_value_path:  'value'

  show_dropdown: ember.computed.or 'is_overflown', 'can_update', 'model.has_notes'

  dropdown_collection: ember.computed 'is_expanded', 'can_update', 'is_overflown', 'are_notes_visible', ->
    overflown_text = if @get('is_expanded') then 'Collapse' else 'Expand'
    notes_text     = if @get('are_notes_visible') then 'Hide Note(s)' else 'View Note(s)'
    can_update     = @get('can_update')
    collection     = []
    collection.push {display: overflown_text,  action: 'toggle_expand'}             if @get('is_overflown')
    collection.push {display: 'Edit',          action: 'toggle_edit_observation'}   if can_update
    collection.push {display: 'Remove',        action: 'destroy_observation_start'} if can_update
    collection.push {display: notes_text,      action: 'toggle_notes_visible'}      if can_update or @get('model.has_notes')
    collection

  init: ->
    @_super()
    timer = setInterval (=> @update_time(@)), 60000
    @set 'timer', timer

  didInsertElement: -> @set_overflown()

  willDestroyElement: ->
    timer = @get('timer')
    clearInterval timer
    @set 'timer', null

  c_observation_edit:      ns.to_p 'observation', 'edit'
  c_observation_note_show: ns.to_p 'observation_note', 'show'
  c_observation_note_new:  ns.to_p 'observation_note', 'new'
  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'

  is_expanded:       false
  is_overflown:      false

  is_editing_obs:    false
  is_destroying_obs: false

  are_notes_visible: false
  is_creating_note:  false

  are_notes_visible_on:  -> @set 'are_notes_visible', true
  are_notes_visible_off: -> @set 'are_notes_visible', false
  create_note_on:        -> @set 'is_creating_note', true
  create_note_off:       -> @set 'is_creating_note', false

  edit_obs_on:     -> @set 'is_editing_obs', true
  edit_obs_off:    -> @set 'is_editing_obs', false
  destroy_obs_on:  -> @set 'is_destroying_obs', true
  destroy_obs_off: -> @set 'is_destroying_obs', false

  not_view_only: ember.computed.not 'totem_scope.is_view_only'
  can_update:    ember.computed.and 'not_view_only', 'model.can.update'
  can_destroy:   ember.computed.and 'not_view_only', 'model.can.destroy'
  has_sortable:  ember.computed.not 'not_view_only'

  actions:

    toggle_expand: -> @toggleProperty('is_expanded')

    toggle_edit_observation: -> if @toggleProperty('is_editing_obs') then @send('edit_observation') else @send('update_observation_cancel')

    edit_observation: ->
      @disable_observation_list()
      @edit_obs_on()

    update_observation: ->
      @sendAction 'update', @get('model')
      @edit_obs_off()

    update_observation_cancel: ->
      @enable_observation_list()
      @edit_obs_off()
      @get('model').rollback()

    destroy_observation_start:  -> @destroy_obs_on()
    destroy_observation_cancel: -> @destroy_obs_off()
    destroy_observation: ->
      @sendAction 'remove', @get('model')
      @destroy_obs_off()

    # ######################### #
    # ### Observation Notes ### #
    # ######################### #
    toggle_notes_visible: ->
      if @toggleProperty('are_notes_visible')
        @send('create_note_start')  if @get('model.has_no_notes')  # auto open new-note if no existing notes
      else
        @send('create_note_cancel') if @get('is_creating_note')

    create_note_start: ->
      @disable_observation_list()
      @create_note_on()

    create_note: (value) ->
      observation = @get('model')
      note = observation.store.createRecord ns.to_p('observation_note'), value: value
      note.set ns.to_p('observation'), observation
      note.save().then (note) =>
        @totem_messages.api_success(source: @, model: note, action: 'save', i18n_path: ns.to_o('observation_note', 'save'))
      , (error) =>
        @totem_messages.api_failure(error, source: @, model: note)
      @create_note_off()
      @enable_observation_list()

    create_note_cancel: ->
      @create_note_off()
      @are_notes_visible_off()  unless @get('model.has_notes')
      @enable_observation_list()

    edit_note_start: ->
      @edit_obs_off()
      @disable_observation_list()

    update_note_cancel: (note) ->
      note.rollback() if note.get('isDirty')
      @enable_observation_list()

    update_note: (note) ->
      note.save().then (note) =>
        @totem_messages.api_success(source: @, model: note, action: 'save', i18n_path: ns.to_o('observation_note', 'save'))
      , (error) =>
        @totem_messages.api_failure(error, source: @, model: note)
      @enable_observation_list()

    destroy_note: (note) ->
      observation = @get 'model'
      note.deleteRecord()
      note.save().then (note) =>
        @totem_messages.api_success(source: @, model: note, action: 'delete', i18n_path: ns.to_o('observation_note', 'destroy'))
        observation.get(ns.to_p 'observation_notes').then (notes) =>
          @are_notes_visible_off()  if notes.get('length') == 0
      , (error) =>
        @totem_messages.api_failure(error, source: @, model: note)

  enable_observation_list:  -> @$().addClass(@draggable_class)
  disable_observation_list: -> @$().removeClass(@draggable_class)

  check_overflow: ember.observer 'model.value', -> @set_overflown()

  update_time: (comp) ->
    model      = comp.get('model')
    created_at = model.get('created_at') if model
    return unless created_at
    from_now       = moment(created_at).fromNow()
    $obs_item_date = @$().find('.obs-item-date')
    $obs_item_date.text(from_now)

  overflown_selector: '.obs-list_list-item-value'

  set_overflown: ->
    selector = @get 'overflown_selector'
    $value   = @$(selector)
    return if ember.isBlank($value)
    element  = $value[0]
    return unless element
    @set 'is_overflown', element.scrollWidth > element.clientWidth
