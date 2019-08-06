import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/components/wizards/steps/base'
import i18n  from 'totem/i18n'
export default base.extend
  # Properties
  step:        'confirmation'
  page_title:  ember.computed.reads 'model.title'
  button_text: ember.computed 'is_editing', ->
    is_editing = @get 'is_editing'
    if is_editing then i18n.message(path: 'builder.casespace.buttons.save') else i18n.message(path: 'builder.casespace.buttons.create')
