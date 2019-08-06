import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  manager: ember.inject.service ns.to_p('peer_assessment', 'builder', 'manager')