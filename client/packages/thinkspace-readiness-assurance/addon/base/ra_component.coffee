import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  ra: ember.inject.service ns.to_p('ra')

  init: ->
    @_super()
    @ra = @get('ra')
