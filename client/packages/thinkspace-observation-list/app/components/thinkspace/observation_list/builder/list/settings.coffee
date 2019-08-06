import ember          from 'ember'
import ns             from 'totem/ns'
import ta             from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  model:             null
  groups:            null
  assignable_groups: null

  is_creating_group: false

  # ##### Group properties
  group_title: null

  # ### Computed properties
  has_groups:              ember.computed.notEmpty 'model.groups'
  has_assignable_groups:   ember.computed.notEmpty 'assignable_groups'
  valid_assignable_groups: ember.computed 'model.groups.length', 'assignable_groups.length', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.get('groups').then (groups) =>
        assignable_groups = @get 'assignable_groups'
        assignable_groups = ember.makeArray assignable_groups
        filtered_groups   = assignable_groups.filter (group) => !groups.contains(group)
        resolve(filtered_groups)
    ta.PromiseArray.create promise: promise

  # ### Components
  c_loader:   ns.to_p 'common', 'loader'
  c_dropdown: ns.to_p 'common', 'dropdown'

  # ### Events
  init: ->
    @_super()
    @get_groups().then => @get_assignable_groups().then => @set_all_data_loaded()

  # ### Group helpers
  get_groups: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      query =
        id:     model.get 'id'
        action: 'groups'
        verb:   'GET'
      @tc.query(ns.to_p('list'), query, payload_type: ns.to_p('observation_list:group')).then (groups) =>
        @set 'groups', groups
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  get_assignable_groups: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      query =
        id:     model.get 'id'
        action: 'assignable_groups'
        verb:   'GET'
      @tc.query(ns.to_p('list'), query, payload_type: ns.to_p('observation_list:group')).then (groups) =>
        @set 'assignable_groups', groups
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  # ### Helpers
  get_store: -> @container.lookup('store:main')

  group_assignment: (group, action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      query = 
        group_id: group.get 'id'
        id:       model.get 'id'
        verb:     'PUT'
        action:   action
      @tc.query(ns.to_p('list'), query, single: true).then (list) =>
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  reset_is_creating_group: -> @set 'is_creating_group', false

  actions:
    toggle_is_creating_group: -> @toggleProperty 'is_creating_group'
    cancel_is_creating_group: -> @reset_is_creating_group()

    create_group: ->
      @totem_messages.show_loading_outlet()

      builder = @get 'builder'
      title   = @get 'group_title'
      store   = @get_store()

      builder.get_assignment().then (assignment) =>
        type_path = @totem_scope.standard_record_path(assignment)
        group     = store.createRecord ns.to_p('observation_list:group'),
          groupable_type: type_path
          groupable_id:   assignment.get 'id'
          title: title
        group.save().then (group) =>
          assignable_groups = @get 'assignable_groups'
          assignable_groups.pushObject group
          @set 'group_title', null
          @reset_is_creating_group()
          @totem_messages.hide_loading_outlet()

    assign_group: (group) ->
      @totem_messages.show_loading_outlet()
      @group_assignment(group, 'assign_group').then =>
        @totem_messages.hide_loading_outlet()

    unassign_group: (group) ->
      @totem_messages.show_loading_outlet()
      @group_assignment(group, 'unassign_group').then =>
        @totem_messages.hide_loading_outlet()