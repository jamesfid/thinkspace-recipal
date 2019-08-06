import ember  from 'ember'

export default ember.Mixin.create

  handle_cancel: (clone, el, container, source) ->
    return unless @list_container == container
    $el     = $(el)
    pos_x   = @get_element_pos_x($(clone))
    item    = @get_element_item($el)
    delta_x = pos_x - item.pos_x
    return if delta_x == 0
    children  = @get_item_change_position_children(item)
    @change_item_pos_x(item, delta_x)
    @change_item_pos_x(children, delta_x)
    @reset_has_children(item)
    @save_response()

  handle_drop: (clone, el, target, source, sibling) ->
    sibling = @get_sibling(sibling)
    pos_x   = @get_element_pos_x($(clone))
    index   = @get_change_item_index_from_sibling_element(sibling)
    if @list_container == source
      @drop_move_item(pos_x, el, index)
    else
      @drop_new_item(pos_x, el, source, index)

  drop_move_item: (pos_x, el, index) ->
    $el  = $(el)
    item = @get_element_item($el)
    @change_item_position(item, index, pos_x: pos_x).then =>
      $el.remove()
      @reset_has_children(item)
      @save_response()

  drop_new_item: (pos_x, el, source, index) ->
    $el = $(el)
    @get_new_item($el, pos_x, source).then (new_item) =>
      $el.remove()
      @value_items.insertAt(index, new_item)
      @reset_has_children(new_item)
      @select_item(new_item)
      @save_response()

  get_element_pos_x: ($el) ->
    cleft = $(@list_container).offset().left
    eleft = $el.offset().left or 0
    left  = eleft - cleft
    if (left and left > 0) then pos_x = Math.floor(left / @indent_px) else pos_x = 0
    pos_x = @max_indent if pos_x > @max_indent
    pos_x



