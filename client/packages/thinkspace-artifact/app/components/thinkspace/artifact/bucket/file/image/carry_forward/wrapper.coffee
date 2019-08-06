import ember  from 'ember'
import ns     from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['artifact_image-wrapper', 'clearfix']

  c_image_file: ns.to_p 'artifact', 'bucket', 'file', 'image', 'carry_forward', 'file'

  is_expert: ember.computed.equal 'tag_attrs.expert', 'true'
