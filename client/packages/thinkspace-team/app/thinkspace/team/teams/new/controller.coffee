import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-team/controllers/base'

export default base.extend

  model_validation_message: null
  actions:                  
    save: ->
      team = @get('model')
      category_id = team.get('category_id') # TODO: REMOVE NO LONGER NEEDED.
      @totem_error.throw @, "Team #{team.get('id')} category is blank."  unless category_id
      @store.find(ns.to_p('category'), category_id).then (category) =>
        team.set ns.to_p('category'), category  # a new record needs the category association path for server authorization
        team.save().then (team) =>
          @totem_messages.api_success source: @, model: team, action: 'save', i18n_path: ns.to_o('team', 'save')
          @transition_to_index()
        , (error) =>
          @totem_messages.api_failure error, source: @, model: team, action: 'save', without_key: false
          @set 'model_validation_message', team.get('validation_message')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: team, action: 'save'
        @totem_error.throw @, "Error getting team category [id: #{category_id}]."
    cancel: ->
      team = @get('model')
      team.unloadRecord()
      @transition_to_index()
    clear_model_errors: -> @set 'model_validation_message', null
