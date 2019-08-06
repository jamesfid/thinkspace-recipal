import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-team/controllers/base'

export default base.extend

  model_validation_message: null
  actions:                  
    save: ->
      team = @get('model')
      if team.get('isDirty')
        team.save().then (team) =>
          @totem_messages.api_success source: @, model: team, action: 'save', i18n_path: ns.to_o('team', 'save')
          @transition_to_index()
        , (error) =>
          @totem_messages.api_failure error, source: @, model: team, action: 'save', without_key: false
          @set 'model_validation_message', team.get('validation_message')
      else
        @transition_to_index()
    cancel: ->
      team = @get('model')
      team.rollback()
      @transition_to_index()
    clear_model_errors: -> @set 'model_validation_message', null
