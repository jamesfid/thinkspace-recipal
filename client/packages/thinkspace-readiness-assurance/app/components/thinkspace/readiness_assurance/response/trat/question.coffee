import ember     from 'ember'
import val_mixin from 'totem/mixins/validations'
import base      from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend val_mixin,
  tagName:    'li'
  classNames: ['ts-ra_question']

  actions:
    select_answer: (id) -> @qm.save_answer(id)

    save_justification: (value) -> @qm.save_justification(value).then => @qm.unlock()

    cancel_justification: ->
      @qm.reset_values()
      @qm.unlock()

    focus_justification: -> @qm.lock()

    toggle_chat: ->
      if @toggleProperty 'qm.chat_displayed'
        @sendAction 'chat', @qm.qid
      else
        @sendAction 'chat_close', @qm.qid

  answer_id: ember.computed.reads 'qm.answer_id'

  validations:
    answer_id:
      presence:
        message: 'You must select one of the above choices'
