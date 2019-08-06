import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  space_id: null

  # Services
  wizard_manager: ember.inject.service()

  actions:                       
    exit: -> @get('wizard_manager').exit()
