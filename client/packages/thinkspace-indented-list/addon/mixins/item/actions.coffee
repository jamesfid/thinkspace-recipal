import ember from 'ember'

export default ember.Mixin.create

  new_top: ->
    return if @readonly
    new_item = {pos_y: 0, pos_x: 0}
    @value_items.insertAt(0, new_item)
    @save_response()
    
  new_bottom: ->
    return if @readonly
    bottom   = @get_value_items_bottom_index()
    new_item = {pos_y: bottom, pos_x: 0}
    @value_items.insertAt(bottom, new_item)
    @save_response()

  remove_item: (item) ->
    return if @readonly
    prev_item = @get_prev_item(item)
    num_items = 1
    children  = @get_item_children(item)
    num_items += children.length if @include_item_children_on_change(item)
    index     = @value_items.indexOf(item)
    @value_items.removeAt(index, num_items)
    @reset_has_children(prev_item)  if prev_item
    @save_response()
    items = [item]
    items = items.concat(children) if num_items > 1
    @clear_itemable_is_used_unless_used_by_another_item(items).then => return

