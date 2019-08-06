import ember  from 'ember'

export default ember.Mixin.create

  get_value_items_bottom_index: -> if @value_items.length <= 0 then 0 else @value_items.length

  get_visible_next: ($el) -> $el.nextAll(':visible:first')
  get_visible_prev: ($el) -> $el.prevAll(':visible:first')

  has_item_children: (item) ->
    pos_x = item.pos_x
    start = @value_items.indexOf(item)
    return false unless start?
    start += 1
    end    = @get_value_items_last_index()
    return false if start > end
    for i in [start..end]
      child_item = @value_items[i]
      return true  if child_item.pos_x > pos_x 
      return false if child_item.pos_x <= pos_x 
    false

  get_item_children: (item, visible=true) ->
    children = []
    pos_x    = item.pos_x
    start    = @value_items.indexOf(item)
    return children unless start?
    start += 1
    end    = @get_value_items_last_index()
    return children if start > end
    for i in [start..end]
      child_item = @value_items[i]
      return children if child_item.pos_x <= pos_x 
      # Only return visible items unless specified.
      if visible
        children.push(child_item)
      else
        comp         = @get_item_component(child_item)
        item_visible = comp.get('item_visible')
        children.push(child_item) unless item_visible
    children

  get_item_parent: (item) ->
    pos_x = item.pos_x
    index = @value_items.indexOf(item)
    return null unless index > 0
    end = index - 1
    for i in [0..end]
      pi = end - i
      parent_item = @value_items[pi]
      return parent_item if parent_item.pos_x <= pos_x
      return null if pi == end
    null

  get_prev_item: (item) ->
    index = @value_items.indexOf(item)
    return null unless index > 0
    @value_items[index - 1]

  get_next_item: (item) ->
    index = @value_items.indexOf(item)
    return null unless index >= 0
    return null if index == @get_value_items_last_index()
    @value_items[index + 1]

  get_value_items_last_index: ->
    index = @value_items.length - 1
    if index >= 0 then index else 0
