import ember from 'ember'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  thinkspace: ember.inject.service()

  titleToken: (model) -> model.get('title') + ' Roster'

  activate: ->  @get('thinkspace').disable_wizard_mode()

  model: (params) -> @get_space_from_params(params)
