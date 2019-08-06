import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['ts-componentable']

  # ### Services
  tvo:             ember.inject.service()

  # ### Components
  c_bucket_upload: ns.to_p 'artifact', 'bucket', 'upload'
  c_bucket_file:   ns.to_p 'artifact', 'bucket', 'file'

  init: ->
    @_super()
    @get('tvo.helper').load_ownerable_view_records @get('model')