import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  has_none: ember.computed.equal 'responses.length', 0
  has_one:  ember.computed.equal 'responses.length', 1
  has_many: ember.computed.gt    'responses.length', 1

  response: ember.computed.reads 'responses.firstObject'