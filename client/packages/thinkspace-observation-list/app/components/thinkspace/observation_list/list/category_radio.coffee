import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  category_id:    ember.computed.reads 'category.id'
  category_label: ember.computed.reads 'category.label'

  is_checked: ember.computed 'input_value', -> @get('input_value') == @get('category_id')

  actions:
    toggle_radio: -> if @get('is_checked') then @sendAction 'uncheck' else @sendAction 'check', @get('category_id')
