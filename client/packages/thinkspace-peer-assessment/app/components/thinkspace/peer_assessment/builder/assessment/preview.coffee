import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  manager: ember.inject.service ns.to_p('peer_assessment', 'builder', 'manager')
  
  # ### Properties
  model: null

  # ### Computed properties
  quant_items: ember.computed.reads 'model.quant_items'
  qual_items:  ember.computed.reads 'model.qual_items'

  # ### Components
  c_quant_preview: ns.to_p 'peer_assessment', 'builder', 'assessment', 'quant', 'preview'
  c_qual_preview:  ns.to_p 'peer_assessment', 'builder', 'assessment', 'qual', 'preview'

  # ### Events
  init: ->
    @_super()
    @get('manager').set_model @get 'model'