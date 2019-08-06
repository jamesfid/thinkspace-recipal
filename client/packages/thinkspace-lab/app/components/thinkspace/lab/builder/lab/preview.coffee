import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Properties
  # ### Properties
  selected_category:             null
  is_viewing_keyboard_shortcuts: false
  
  # ### Components
  c_select_category: ns.to_p 'lab:chart', 'select_category'

  # ### Events
  willInsertElement: ->
    chart          = @get 'model'
    chart.get(ns.to_p('lab:categories')).then (categories) =>
      first_category = categories.sortBy('position').get('firstObject')
      @set 'selected_category', first_category if ember.isPresent(first_category)

  actions:
    select:                    (category) -> @set 'selected_category', category
    toggle_keyboard_shortcuts: -> @toggleProperty 'is_viewing_keyboard_shortcuts'
