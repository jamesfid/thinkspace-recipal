import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  builder: ember.inject.service()
  manager: ember.inject.service ns.to_p('peer_assessment', 'builder', 'manager')

  # ### Properties
  action_handler: null

  actions:
    add_quant_item:       -> @get('action_handler').send 'add_quant_item'
    add_qual_item: (type) -> @get('action_handler').send 'add_qual_item', type
