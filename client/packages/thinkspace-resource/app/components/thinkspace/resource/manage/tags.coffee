import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  c_manage_tag:     ns.to_p 'resource', 'manage', 'tag'
  c_manage_tag_new: ns.to_p 'resource', 'manage', 'tag', 'new'

  create_visible: false

  actions:
    close:  -> @sendAction 'close'
    create: -> @set 'create_visible', true
    cancel: -> @set 'create_visible', false
