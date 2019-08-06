import ember from 'ember'

export default ember.View.extend
  tagName: 'option'
  templateName: 'select/option'
  classNameBindings: ['class_names']
  attributeBindings: ['selected', 'disabled', 'value']

  # Provided by the select view
  is_record:                true
  content_display_property: null
  class_names:              ''
  selected_items:           []
  disabled_items:           []
  empty:                    false
  data_placeholder:         'Select an Option'

  parent_view:              ember.computed.alias 'parentView'
  totem_select_id_property: ember.computed.alias 'parent_view.totem_select_id_property'
  
  value: ( ->
    totem_select_id_property = @get('totem_select_id_property')
    return if @get('is_record') then @get("content.#{totem_select_id_property}") else @get('content')
  ).property('is_record', 'content', 'parent_view.select_ids_recomputed')

  display_property: ( ->
    return @get('data_placeholder') if @get('empty')
    if @get('is_record')
      property = @get('content_display_property')
      return @get("content.#{property}")
    else
      return @get('content')
  ).property('content', 'content_display_property', 'is_record')

  selected: ( ->
    selected_items = @get('selected_items')
    selected_items = ember.makeArray(selected_items)
    content        = @get('content')
    selected_items.contains(content)
  ).property('selected_items', 'selected_items.@each', 'content')

  disabled: ( ->
    disabled_items = @get('disabled_items')
    disabled_items = ember.makeArray(disabled_items)
    content        = @get('content')
    disabled_items.contains(content)
  ).property('disabled_items', 'disabled_items.@each', 'content')