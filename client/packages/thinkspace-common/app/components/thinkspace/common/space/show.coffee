import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  c_space_header: ns.to_p 'space', 'header'
  c_loader:       ns.to_p 'common', 'shared', 'loader'
