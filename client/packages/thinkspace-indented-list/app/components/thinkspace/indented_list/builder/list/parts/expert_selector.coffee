import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  lists:         null
  users:         null
  selected_list: null
  selected_user: null

  # ### Computed properties
  has_selected_list: ember.computed.notEmpty 'selected_list'
  has_selected_user: ember.computed.notEmpty 'selected_user'
  has_both_selected:  ember.computed.and 'has_selected_list', 'has_selected_user'

  # ### Components
  c_loader:             ns.to_p 'common', 'loader'
  c_ownerable_selector: ns.to_p 'casespace', 'ownerable', 'selector'

  # ### Events
  init: ->
    @_super()
    @set_indented_lists().then => @set_roster().then => @set_all_data_loaded()

  # ### Init helpers
  set_indented_lists: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('builder').get_assignment().then (assignment) =>
        query =
          id:                 assignment.get 'id'
          action:             'phase_componentables'
          componentable_type: ns.to_p 'indented:list'
        @tc.query(ns.to_p('assignment'), query, payload_type: ns.to_p('indented:list')).then (lists) =>
          lists = lists.filterBy 'expert', false
          @set 'lists', lists
          resolve()
        , (error) => @error(error)
      , (error) => @error(error)
    , (error) => @error(error)

  set_roster: ->
    new ember.RSVP.Promise (resolve, reject) =>
      builder = @get 'builder'
      builder.get_roster().then (users) =>
        @set 'users', users
        resolve()
      , (error) => @error(error)
    , (error) => @error(error)

  # ### Helpers
  reset_selected_list: -> @set 'selected_list', null
  reset_selected_user: -> @set 'selected_user', null
  reset_all_selected:  -> @reset_selected_user(); @reset_selected_list()

  actions:
    select_list: (list)  -> @set 'selected_list', list
    select_user: (user)  -> @set 'selected_user', user
    reset_selected_list: -> @reset_selected_list()
    reset_selected_user: -> @reset_all_selected()

    set_expert_response: ->
      model = @get 'model'
      list  = @get 'selected_list'
      user  = @get 'selected_user'
      query = 
        action:  'set_expert_response'
        id:      model.get 'id'
        list_id: list.get 'id'
        user_id: user.get 'id'
        verb: 'PUT'

      @totem_messages.show_loading_outlet()
      @tc.query(ns.to_p('indented:list'), query).then =>
        @reset_all_selected()
        @totem_messages.hide_loading_outlet()
      , (error) =>
        @reset_all_selected()
        @totem_messages.hide_loading_outlet()

    cancel: -> @reset_all_selected()
