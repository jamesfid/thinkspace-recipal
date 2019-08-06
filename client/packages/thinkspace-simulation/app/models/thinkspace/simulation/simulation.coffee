import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'authable'
  ),

  authable_type: ta.attr('string')
  authable_id:   ta.attr('number')
  path:          ta.attr('string')