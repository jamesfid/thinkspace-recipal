import ember from 'ember'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  file_url: ember.computed -> @get('model.url') 