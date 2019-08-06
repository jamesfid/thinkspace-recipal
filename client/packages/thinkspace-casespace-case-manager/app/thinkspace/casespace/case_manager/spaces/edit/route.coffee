import ember from 'ember'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend

  model: (params) -> @get_space_from_params(params)
