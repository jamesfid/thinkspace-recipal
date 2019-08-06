import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
    ta.has_many    'indented:responses', reads: {filter: true, notify: true}
    ta.has_many    'indented:expert_responses'
  ),

  title:         ta.attr('string')
  authable_id:   ta.attr('number')
  authable_type: ta.attr('string')
  expert:        ta.attr('boolean')
  settings:      ta.attr()

  layout: ember.computed.reads 'settings.layout'
