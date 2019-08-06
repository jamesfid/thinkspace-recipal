import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  model: null

  # Components
  c_library_manager: ns.to_p('markup', 'library', 'edit', 'manager')