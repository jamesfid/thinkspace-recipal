import ember  from 'ember'

export default ember.Mixin.create

  change_item_pos_x: (items, delta_x) ->
    return if ember.isBlank(items)
    ember.makeArray(items).forEach (item) =>
      pos_x = item.pos_x + delta_x
      @set_item_pos_x(item, pos_x)
      @reset_item_component_indent(item)

  change_item_position: (item, to_index, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if ember.isBlank(to_index)
      children  = @get_item_change_position_children(item)
      index     = @value_items.indexOf(item)
      num_items = children.length + 1
      new_index = if index < to_index then (to_index - num_items) else to_index
      map       = @new_options_item_property_map(options)
      @populate_item_component_property_map(item, map)
      @populate_item_component_property_map(children, map)
      @value_items.removeAt(index, num_items)
      options.children = children
      @change_item_position_items(item, new_index, options).then =>
        resolve()

  change_item_position_items: (item, index, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      children = options.children or []
      pos_x    = options.pos_x
      if ember.isPresent(pos_x)
        delta_x = pos_x - item.pos_x
        @set_item_pos_x(item, pos_x)
      @value_items.insertAt(index, item)
      children.forEach (child_item) =>
        index            += 1
        child_item.pos_x += delta_x  if ember.isPresent(delta_x)
        @value_items.insertAt(index, child_item)
      ember.run.schedule 'afterRender', @, =>
        @restore_item_component_properties(options)
        @select_item(item)
        resolve()

  get_change_item_index_from_sibling_element: (sibling) ->
    return @get_value_items_bottom_index() if ember.isBlank(sibling)
    @get_change_item_index_from_sibling_item @get_visible_item($(sibling))

  get_change_item_index_from_sibling_item: (sibling_item) ->
    return @get_value_items_bottom_index() unless (sibling_item and ember.isPresent(sibling_item))
    @value_items.indexOf(sibling_item)

  get_item_change_position_children: (item) ->
    if @include_item_children_on_change(item) then @get_item_children(item, false) else []

  get_visible_item: ($el) ->
    return @get_element_item($el)  if @is_element_visible($el)
    $next = @get_visible_next($el)
    ember.isPresent($next) and @get_element_item($next)

  include_item_children_on_change: (item) -> @has_item_children(item) and not @are_item_children_visible(item)

  is_element_visible: ($el)         -> @is_item_visible @get_element_item($el)
  is_item_visible:   (item)         -> item and @get_item_component(item).get('item_visible')
  are_item_children_visible: (item) -> @get_item_component(item).get('children_visible')

  # ###
  # ### Populate/Restore Item Component Properties.
  # ###

  map_component_properties: ['item_visible', 'children_visible', 'is_selected', 'overflow_visible']

  new_options_item_property_map: (options) -> options.item_property_map = ember.Map.create()

  populate_item_component_property_map: (items, map) ->
    ember.makeArray(items).forEach (item) =>
      map.set item, @get_item_component_properties(item)

  restore_item_component_properties: (options) ->
    map = options.item_property_map
    return if ember.isBlank(map)
    map.forEach (props, item) => @set_item_component_properties(item, props)

  get_item_component_properties: (item) ->
    props = @map_component_properties or []
    comp  = @get_item_component(item)
    comp.getProperties(props...)

  set_item_component_properties: (item, props) ->
    comp = @get_item_component(item)
    comp.setProperties(props)

  # ###
  # ### Reset Component.
  # ###

  reset_item_component_indent: (items) ->
    ember.makeArray(items).forEach (item) =>
      comp = @get_item_component(item)
      comp.set_indent()

  reset_has_children: (item) ->
    ember.run.schedule 'afterRender', @, =>
      @reset_prev_item_component_has_children(item)
      @reset_next_item_component_has_children(item)
      @reset_item_component_has_children(item)
      @reset_number_of_children(item)

  reset_prev_parent_item_component_has_children: (item) ->
    prev_item = @get_prev_item(item)
    return unless prev_item
    prev_parent_item = @get_item_parent(prev_item)
    if prev_parent_item
      items = @get_item_children(prev_parent_item)
      items.push(prev_parent_item)
      @reset_item_component_has_children(items)
    else
      @reset_item_component_has_children(prev_item)

  reset_prev_item_component_has_children: (item) ->
    prev_item = @get_prev_item(item)
    @reset_item_component_has_children(prev_item)  if prev_item

  reset_next_item_component_has_children: (item) ->
    next_item = @get_next_item(item)
    @reset_item_component_has_children(next_item)  if next_item

  reset_item_component_has_children: (items) ->
    ember.makeArray(items).forEach (item) =>
      comp = @get_item_component(item)
      comp.set_has_children()

  reset_number_of_children: (item) ->
    comp = @get_item_component(item)
    comp.set_number_of_children()
