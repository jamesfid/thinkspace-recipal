import ember from 'ember'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend

  model: (params) -> @get_phase_from_params(params)

  afterModel: (model) -> @set_current_models(phase: model).then => @load_assignment()
