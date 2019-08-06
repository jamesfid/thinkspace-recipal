import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-team/controllers/base'

export default base.extend

  model_validation_message: null
  actions:                  
    destroy: ->
      team = @get('model')
      @unload_team_associations(team).then =>
        team.deleteRecord()
        team.save().then (team) =>
          @totem_messages.api_success source: @, model: team, action: 'destroy', i18n_path: ns.to_o('team', 'destroy')
          @transition_to_index()
        , (error) =>
          @totem_messages.api_failure error, source: @, model: team, action: 'destroy', without_key: false
          @set 'model_validation_message', team.get('validation_message')
    cancel: -> @transition_to_index()
  unload_team_associations: (team) ->
    new ember.RSVP.Promise (resolve, reject) =>
      team.get(ns.to_p 'team_teamables').then (team_teamables) =>
        team.get(ns.to_p 'team_viewers').then (team_viewers) =>
          team_teamables.map (team_teamable) -> team_teamable.unloadRecord()
          team_viewers.map   (team_viewer)   -> team_viewer.unloadRecord()

          # Unload team_viewer records that this team is a viewer.
          team_path = @totem_scope.get_record_path(team)
          team_id   = parseInt(team.get 'id')
          viewing   = @store.all(ns.to_p 'team_viewer').filter (team_viewer) => 
            viewer_path = @totem_scope.rails_polymorphic_type_to_path(team_viewer.get 'viewerable_type')
            team_path == viewer_path and team_id == team_viewer.get('viewerable_id')
          viewing.map (team_team_viewer) => team_team_viewer.unloadRecord()
          resolve()
