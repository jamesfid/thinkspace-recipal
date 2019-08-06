import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName:       ''

  c_space:      ns.to_p 'space', 'space'
  r_spaces_new: ns.to_r 'case_manager', 'spaces', 'new'

  totem_data_config: ability: {ajax_source: ns.to_p('spaces')}, metadata: true
