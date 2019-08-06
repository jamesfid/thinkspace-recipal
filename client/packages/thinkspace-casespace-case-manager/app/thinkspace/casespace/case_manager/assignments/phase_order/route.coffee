import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  titleToken: (model) -> 'Phase Order ' + model.get('title')

  model: (params) -> @get_assignment_from_params(params)

  afterModel: (model) -> @set_current_models(assignment: model).then => @load_assignment()
