import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  is_inviting: false

  # Components
  c_space_header:      ns.to_p 'space', 'header'
  c_new_invitation:    ns.to_p 'invitation', 'new'
  c_space_user_table:  ns.to_p 'space_user', 'table'
  c_file_upload:       ns.to_p 'common', 'file-upload'
  c_file_upload_modal: ns.to_p 'case_manager', 'shared', 'import_roster_modal'

  # Roster import
  import_form_action:  ember.computed 'model', -> "/api/thinkspace/common/spaces/#{@get('model.id')}/import"
  import_model_path:   'thinkspace/common/space'
  import_params:       ember.computed 'model', -> {id: @get('model.id')}
  import_btn_text:     'Import Roster'
  import_loading_text: 'Importing roster..'

  # Team import
  import_team_form_action:  ember.computed 'model', -> "/api/thinkspace/common/spaces/#{@get('model.id')}/import_teams"
  import_team_model_path:   'thinkspace/common/space'
  import_team_params:       ember.computed 'model', -> {id: @get('model.id')}
  import_team_btn_text:     'Import Team Roster'
  import_team_loading_text: 'Importing team roster..'
  c_team_file_upload_modal: ns.to_p 'case_manager', 'team_sets', 'import_modal'

  space_users: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      space = @get 'model'
      @roster_ajax('get', 'roster').then (space_users) =>
        filter = space.store.filter ns.to_p('space_user'), (record) => parseInt(record.get('space_id')) == parseInt(space.get('id'))
        resolve(filter)
    ds.PromiseArray.create promise: promise

  sorted_space_users: ember.computed 'space_users.length', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('space_users').then (space_users) =>
        sortby = space_users.sortBy 'user.last_name'
        resolve(sortby)
    ds.PromiseArray.create promise: promise

  sorted_active_space_users: ember.computed 'sorted_space_users.@each.state', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('sorted_space_users').then (space_users) =>
        filtered = space_users.filter (su) => su.get('is_active')
        resolve(filtered)
    ds.PromiseArray.create promise: promise

  sorted_inactive_space_users: ember.computed 'sorted_space_users.@each.state', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('sorted_space_users').then (space_users) =>
        filtered = space_users.filter (su) => su.get('is_inactive')
        resolve(filtered)
    ds.PromiseArray.create promise: promise

  roster_ajax: (verb, action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      query = 
        id:     model.get('id')
        action: action
        verb:   verb
      @tc.query(ns.to_p('space'), query, payload_type: ns.to_p('space_user')).then (records) =>
        resolve records
  actions:
    toggle_inviting: -> @toggleProperty 'is_inviting'
    cancel_inviting: -> @set 'is_inviting', false
