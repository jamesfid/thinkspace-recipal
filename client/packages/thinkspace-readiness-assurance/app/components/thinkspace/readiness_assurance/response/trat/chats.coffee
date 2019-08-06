import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  chat_managers: ember.computed 'chat_ids.@each', ->
    managers = []
    chat_ids = @get('chat_ids') or []
    for qid in chat_ids
      # TODO: Error check for qid not found.
      cm = @rm.chat_manager_map.get(qid)
      qm = @rm.question_manager_map.get(qid)
      managers.push
        cm: cm
        qm: qm
    managers

  actions:
    close: (qid) ->
      @sendAction 'close', qid
