import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'

export default base.extend
  # Properties
  step:       'confirmation'
  page_title: ember.computed.reads 'model.title'
  team_set:   ember.computed.reads 'wizard_manager.wizard.team_set'