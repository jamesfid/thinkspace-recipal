import ember            from 'ember'
import ns               from 'totem/ns'
import response_manager from 'thinkspace-readiness-assurance/response_manager'
import base             from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  willInsertElement: ->
    console.warn @
    @ra.load_messages()
    @totem_data.ability.refresh().then =>
      is_readonly = @get('viewonly')
      assessment  = @get('model')
      rm          = response_manager.create(container: @container)
      rm.init_manager
        assessment:            assessment
        readonly:              is_readonly
        can_update_assessment: @can.update
        trat:                  true
        room_users_header:     'Team Members'
      @set 'rm', rm

  chat_ids: []

  actions:
    chat: (qid) ->
      @get('chat_ids').pushObject(qid)

    chat_close: (qid) ->
      chat_ids = @get('chat_ids')
      if ember.isBlank(qid)
        chat_ids.clear()
      else
        @set 'chat_ids', chat_ids.without(qid)

