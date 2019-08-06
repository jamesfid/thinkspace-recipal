import ember from 'ember'
import ajax from 'totem/ajax'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  teams:      null
  team_sets:  null
  assignment: null
  has_sent:   false

  # ### Components
  c_assignment_header: ns.to_p 'assignment', 'header'
  c_team:              ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'team'

  init: ->
    @_super()
    @set_assessment().then => @set_teams().then => @set_team_sets().then => @set 'all_data_loaded', true
        

  set_assessment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        model:  ns.to_p 'tbl:assessment'
        verb:   'get'
        action: 'fetch'
        data:
          assignment_id: @get 'assignment.id'

      ajax.object(query).then (payload) =>
        assessment = ajax.normalize_and_push_payload 'tbl:assessment', payload, single: true
        console.log "[tbl-pa-cm] Assessment set to : ", assessment
        @set 'model', assessment
        resolve()

  set_teams: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        model:  ns.to_p 'tbl:assessment'
        verb:   'get'
        action: 'teams'
        id:     @get 'model.id'

      ajax.object(query).then (payload) =>
        teams     = ajax.normalize_and_push_payload 'team', payload
        @set 'teams', teams
        resolve()

  set_team_sets: ->
    new ember.RSVP.Promise (resolve, reject) =>
      query =
        model:  ns.to_p 'tbl:assessment'
        verb:   'get'
        action: 'team_sets'
        id:     @get 'model.id'

      ajax.object(query).then (payload) =>
        team_sets = ajax.normalize_and_push_payload 'tbl:team_set', payload
        console.log "[tbl-pa-cm] Team sets set to: ", team_sets
        @set 'team_sets', team_sets
        resolve()

  get_approve_modal:   -> $('.ts-tblpa_modal')
  show_approve_modal:  -> @get_approve_modal().foundation('reveal', 'open')
  close_approve_modal: -> @get_approve_modal().foundation('reveal', 'close')

  get_notify_all_modal:   -> $('.ts-tblpa_modal-notify')
  show_notify_all_modal:  -> @get_notify_all_modal().foundation('reveal', 'open')
  close_notify_all_modal: -> @get_notify_all_modal().foundation('reveal', 'close')

  actions:
    show_approve_modal:  -> @show_approve_modal()
    close_approve_modal: -> @close_approve_modal()

    show_notify_all_modal:  -> @show_notify_all_modal()
    close_notify_all_modal: -> @close_notify_all_modal()

    approve: ->
      assessment = @get 'model'
      query      = 
        id:     assessment.get 'id'
        action: 'approve'
        verb:   'PUT'
      @totem_messages.show_loading_outlet()
      @tc.query(ns.to_p('tbl:assessment'), query, single: true).then =>
        @totem_messages.hide_loading_outlet()
        @close_approve_modal()
        @set 'has_sent', true

    approve_notify_all: ->
      model = @get 'model'
      id    = @get 'model.id'
      query = 
        id:     id
        action: 'notify_all'
        verb:   'POST'
      @totem_messages.show_loading_outlet()
      @tc.query(ns.to_p('tbl:assessment'), query, single: true).then =>
        @totem_messages.api_success source: @, model: model, action: 'notify_all', i18n_path: ns.to_o('tbl:assessment', 'notify_all')
        @totem_messages.hide_loading_outlet()
        @close_notify_all_modal()
