import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  c_manage_link:     ns.to_p 'resource', 'manage', 'link'
  c_manage_link_new: ns.to_p 'resource', 'manage', 'link', 'new'

  create_visible: false
  prompt:         'No tag'

  actions:
    close:  -> @sendAction 'close'
    create: -> @set 'create_visible', true
    cancel: -> @set 'create_visible', false
