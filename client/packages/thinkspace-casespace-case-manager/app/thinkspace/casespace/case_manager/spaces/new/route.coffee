import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend

  model: (params) -> @store.createRecord ns.to_p('space')

  deactivate: ->
    model = @get 'controller.model'
    model.unloadRecord() if model.get('isNew')
