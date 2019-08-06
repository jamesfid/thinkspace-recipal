import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend

  wizard_manager: ember.inject.service()
  case_manager:   ember.inject.service()

  get_wizard_manager: -> @get('wizard_manager')
  get_case_manager:   -> @get('case_manager')
