import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  builder: ember.inject.service()
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
    @get('builder').set_toolbar @, ns.to_p 'peer_assessment', 'builder', 'assessment', 'toolbar'

  actions:
    add_quant_item: ->
      manager = @get 'manager'
      manager.add_quant_item()

    add_qual_item: (type) ->
      manager = @get 'manager'
      manager.add_qual_item(type)

    save:   -> @sendAction 'set_mode', 'preview'
    cancel: -> @sendAction 'set_mode', 'preview'
