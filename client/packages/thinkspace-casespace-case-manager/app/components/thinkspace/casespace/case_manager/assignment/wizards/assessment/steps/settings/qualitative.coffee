import ember      from 'ember'
import ns         from 'totem/ns'
import base       from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import val_mixin  from 'totem/mixins/validations'

export default base.extend val_mixin,
  # Properties
  has_qualitative_items:   ember.computed.notEmpty 'model'
  has_individual_comments: false

  # Components
  c_qualitative_item: ns.to_p 'case_manager', 'assignment', 'wizards', 'assessment', 'steps', 'settings', 'qualitative', 'item'

  # Upstream actions
  add_qualitative_item:           'add_qualitative_item'
  toggle_has_individual_comments: 'toggle_has_individual_comments'
  remove_qualitative_item:        'remove_qualitative_item'

  actions:
    add: -> @sendAction 'add_qualitative_item'
    toggle_has_individual_comments: -> @sendAction 'toggle_has_individual_comments'
    remove_qualitative_item: (item) -> @sendAction 'remove_qualitative_item', item
    
