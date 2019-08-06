import ember from 'ember'

export default ember.View.extend
  tagName: 'optgroup'
  templateName: 'select/optgroup'
  attributeBindings: ['label']
  
  data_placeholder: 'Select an Option'

  is_record_list:     true
  content:            null
  optgroups:          null
  display_property:   null
  selected_items:     []
  disabled_items:     []
  option_class_names: ''

  parent_view:              ember.computed.alias 'parentView'
  select_ids_recomputed:    ember.computed.alias 'parent_view.select_ids_recomputed'
  totem_select_id_property: ember.computed.alias 'parent_view.totem_select_id_property'

  # Determines the name of the optgroup by comparing the content set with each optgroup set
  label: ( ->
    optgroups = @get('optgroups')
    content   = @get('content')
    for name, group of optgroups
      return name if @compare_arrays(content, group)
    return null
  ).property('content', 'optgroups')

  # An item-by-item comparison of two arrays to determine if they are equal or not
  compare_arrays: (array_a, array_b) ->
    equal = true
    array_a = ember.makeArray(array_a)
    array_b = ember.makeArray(array_b)
    array_a.forEach (a, index) =>
      equal = (array_b.objectAt(index) == a)
      return unless equal
    return equal