import ember from 'ember'
import ns    from 'totem/ns'
import base_component   from 'thinkspace-base/components/base'

export default base_component.extend

  willInsertElement: -> @cm.init_values()

  actions:
    send: ->
      @cm.add_message()

    close: ->
      @qm.set_chat_displayed_off()
      @sendAction 'close', @cm.qid
