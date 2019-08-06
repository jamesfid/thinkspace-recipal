import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  actions:
    close: -> @sendAction 'close'

  help_tip_presentation: ember.computed ->
    tip = @get 'help_tip.html' or ''  # currently only support html help tips
    tip and tip.htmlSafe()
