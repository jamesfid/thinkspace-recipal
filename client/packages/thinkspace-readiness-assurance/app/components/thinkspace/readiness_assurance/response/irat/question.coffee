import ember     from 'ember'
import ns        from 'totem/ns'
import val_mixin from 'totem/mixins/validations'
import base      from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend val_mixin,
  tagName:    'li'
  classNames: ['ts-ra_question']

  actions:
    select_answer:      (id)    -> @qm.save_answer(id)
    save_justification: (value) -> @qm.save_justification(value)

  answer_id: ember.computed.reads 'qm.answer_id'
  
  validations:
    answer_id:
      presence:
        message: 'You must select one of the above choices'
