import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  c_componentable: ember.computed.reads 'model.edit_component'

  is_current: ember.computed 'current_componentable', -> @get('model') == @get('current_componentable')

  actions:
    select: (componentable) -> @sendAction 'select', componentable
