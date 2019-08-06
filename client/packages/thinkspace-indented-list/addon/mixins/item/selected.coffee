import ember  from 'ember'

export default ember.Mixin.create

  select_item: (item, options={}) ->
    ember.run.schedule 'afterRender', @, =>
      comp = @get_item_component(item)
      $el  = @get_item_element(item)
      comp.set 'is_selected', true
      @focus_element($el) unless options.skip_focus

  focus_element: ($el) ->
    $el.focus()

  # ###
  # ### Insert Before/After.
  # ###
  # ### Insert only adds a 'single' item before/after the selected item (e.g. vs duplicate).

  insert_before: (item) -> @process_insert_before_after(item, 0)
  insert_after:  (item) -> @process_insert_before_after(item, 1)

  process_insert_before_after: (item, n) ->
    return if @readonly
    new_item     = {pos_x: item.pos_x}
    index        = @value_items.indexOf(item)
    bottom       = @get_value_items_bottom_index()
    insert_index = index + n
    insert_index = 0                                if index < 0
    insert_index = @get_value_items_bottom_index()  if index > bottom
    @value_items.insertAt(insert_index, new_item)
    @reset_has_children(new_item)
    @select_item(new_item)
    @save_response()

  # ###
  # ### Move Left-Right.
  # ###

  move_left:  (item) -> @process_move_left_right(item, -1)
  move_right: (item) -> @process_move_left_right(item, +1)

  process_move_left_right: (item, n, min=0, max=@max_indent) ->
    return if @readonly
    return if ember.isBlank(item)
    pos_x = item.pos_x
    return if ember.isBlank(pos_x)
    return if n < 0 and pos_x <= min
    return if n > 0 and pos_x >= max
    items = @get_item_change_position_children(item)
    items.push(item)
    @change_item_pos_x(items, n)
    @reset_has_children(item)
    @save_response()

  # ###
  # ### Move Up-Down.
  # ###

  move_up:   (item) -> @process_move_up(item)
  move_down: (item) -> @process_move_down(item)

  process_move_up: (item) ->
    return if @readonly
    return if ember.isBlank(item)
    $el = @get_item_element(item)
    return if ember.isBlank($el)
    $sibling = @get_visible_prev($el)
    index    = @get_change_item_index_from_sibling_element($sibling)
    bottom   = @get_value_items_bottom_index()
    return if index == bottom  # already at top
    @change_item_position(item, index).then =>
      @reset_has_children(item)
      @reset_prev_parent_item_component_has_children(item)
      @reset_next_item_component_has_children(item)
      @save_response()

  process_move_down: (item) ->
    return if @readonly
    return if ember.isBlank(item)
    $el = @get_item_element(item)
    return if ember.isBlank($el)
    $next    = @get_visible_next($el)
    $sibling = @get_visible_next($next)
    index  = @get_change_item_index_from_sibling_element($sibling)
    bottom = @get_value_items_bottom_index()
    $next_visible = @get_visible_next($el)
    return if ember.isBlank($next_visible) and index == bottom  # already at bottom
    @change_item_position(item, index).then =>
      @reset_has_children(item)
      @reset_prev_parent_item_component_has_children(item)
      @reset_next_item_component_has_children(item)
      @save_response()

  # ###
  # ### Duplicate.
  # ###

  duplicate_before: (item) -> @process_duplicate_before_after(item)
  duplicate_after:  (item) -> @process_duplicate_before_after(item, false)

  process_duplicate_before_after: (item, before=true) ->
    return if @readonly
    return if ember.isBlank(item)
    $el = @get_item_element(item)
    return if ember.isBlank($el)
    $sibling  = if before then $el else @get_visible_next($el)
    dup_index = @get_change_item_index_from_sibling_element($sibling)
    dup_item  = ember.merge({}, item)
    options   = @get_item_duplicate_options(item, dup_item)
    @change_item_position_items(dup_item, dup_index, options).then =>
      @reset_has_children(dup_item)
      @select_item(dup_item)
      @save_response()

  get_item_duplicate_options: (item, dup_item) ->
    return if @readonly
    options = {}
    map     = @new_options_item_property_map(options)
    map.set dup_item, @get_item_component_properties(item)
    dup_children = []
    @get_item_change_position_children(item).forEach (child_item) =>
      dup_child = ember.merge({}, child_item)
      dup_children.push(dup_child)
      map.set dup_child, @get_item_component_properties(child_item)
    options.children = dup_children
    options
