import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  titleToken: 'New'

  setupController: (controller, model) ->
    controller.reset_query_params()
    @_super(controller, model)
    
  model: (params) -> 
    @store.find(ns.to_p('space'), params.space_id).then (space) =>
      @get('wizard_manager').set_space space
      @store.createRecord ns.to_p('assignment'),
        space: space

  deactivate: ->
    model = @get 'controller.model'
    model.deleteRecord() if model.get('isNew')
