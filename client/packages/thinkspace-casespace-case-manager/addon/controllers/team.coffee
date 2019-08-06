import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'

export default ember.ObjectController.extend
  needs: [ns.to_p('case_manager')]

  case_manager_controller: ember.computed.reads "controllers.#{ns.to_p('case_manager')}"
  current_space:           ember.computed.reads 'case_manager_controller.current_space'
  current_assignment:      ember.computed.reads 'case_manager_controller.current_assignment'
  current_phase:           ember.computed.reads 'case_manager_controller.current_phase'

  send_case_manager_request: (model, options) -> @get('case_manager_controller').send_case_manager_request(model, options)
  ajax_object:               (options = {})   -> @get('case_manager_controller').ajax_object(options)

  team_route:
    index:   ns.to_p('case_manager', 'teams.index')
    new:     ns.to_p('case_manager', 'teams.new')
    edit:    ns.to_p('case_manager', 'teams.edit')
    destroy: ns.to_p('case_manager', 'teams.destroy')

  # ### Message helpers.
  show_loading_outlet: -> @totem_messages.show_loading_outlet()
  hide_loading_outlet: -> @totem_messages.hide_loading_outlet()

  previous_space: null

  all_teams: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      space = @get 'current_space'
      return resolve([])  unless space
      @set 'previous_space', space  unless @get('previous_space') == space
      # @totem_scope.authable(space)
      @get('all_space_teams').then =>
        resolve @store.filter ns.to_p('team'), (team) =>
          @totem_scope.record_authable_match_authable(team, space) 
    ds.PromiseArray.create promise: promise

  all_space_teams: ember.computed 'previous_space', ->
    space = @get 'current_space'
    @totem_error.throw @, 'A space is required to get space teams.'  unless space
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @show_loading_outlet()
      options = 
        action: 'teams'
        data:
          space_id: space.get('id')
      @send_case_manager_request(space, options).then =>
        @hide_loading_outlet()
        resolve()
      , (error) =>
        @totem_messages.api_failure error, source: @, model: space
    ds.PromiseArray.create promise: promise

  all_team_users: ember.computed 'current_space', ->
    space = @get 'current_space'
    promise = new ember.RSVP.Promise (resolve, reject) =>
      return resolve([])  unless space
      options = 
        action: 'team_users'
        data:
          space_id: space.get('id')
      @ajax_object(options).then (payload) =>
        @totem_messages.api_success source: @, model: space
        users    = payload[ns.to_p('users')]
        user_ids = users.mapBy('id')
        @store.pushPayload(payload)
        users = @store.all(ns.to_p 'user').filter (user) =>
          user_ids.contains parseInt(user.get('id'))
        resolve users.sortBy('sort_name')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: space
    ds.PromiseArray.create promise: promise

  team_categories: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @store.find(ns.to_p 'category').then (categories) =>
        @totem_messages.api_success source: @, model: ns.to_p('category')
        resolve(categories)
      , (error) =>
        @totem_messages.api_failure error, source: @, model: ns.to_p('category')
    ds.PromiseArray.create promise: promise

