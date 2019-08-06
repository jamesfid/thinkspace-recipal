import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.has_many    'ra:responses', reads: {filter: true}
    ta.polymorphic 'authable'
  ),

  title:             ta.attr('string')
  question_settings: ta.attr()
  authable_id:       ta.attr('number')
  authable_type:     ta.attr('string')
  # below attributes only populated when on dashboard (e.g. admin)
  settings: ta.attr()
  answers:  ta.attr()

  questions: ember.computed.reads 'question_settings'

  get_question_ids: -> @get('questions').mapBy 'id'

  get_question_by_id: (id) -> @get('questions').findBy 'id', id
