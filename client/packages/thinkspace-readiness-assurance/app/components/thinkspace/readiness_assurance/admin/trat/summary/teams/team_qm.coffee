import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  chat_messages: ember.computed.reads 'cm.messages'

  init: ->
    @_super()
    @qid = @qm.qid
    @rm  = @qm.rm
    @cm  = @rm.chat_manager_map.get(@qid)
