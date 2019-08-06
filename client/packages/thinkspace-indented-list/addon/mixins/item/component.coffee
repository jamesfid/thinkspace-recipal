import ember  from 'ember'
# ### Methods called by a component. ### #
export default ember.Mixin.create

  get_item_value: (item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      description = item.description
      return resolve(description)  if ember.isPresent(description)
      @get_item_itemable(item).then (itemable) =>
        value_path = item.itemable_value_path
        if ember.isBlank(itemable) or ember.isBlank(value_path)
          resolve item.description or @default_item_description()
        else
          resolve itemable.get(value_path)

  set_all_items_visibility: (visible) -> @set_children_items_visibility(@value_items, visible)

  set_children_items_visibility: (items, visible) ->
    min_x = @get_minimum_pos_x()

    items.forEach (item) =>
      comp = @get_item_component(item)
      comp.set 'item_visible', visible  unless item.pos_x == min_x
      if comp.get('has_children')
        comp.set 'children_visible', visible
        
    # Set number of children aftwerwards to ensure the count is correct when packing all.
    items.forEach (item) =>
      comp = @get_item_component(item)
      comp.set_number_of_children()

  show_confirm_remove: -> @confirm_remove

  calc_item_indent: (item) -> (item.pos_x or 0) * @indent_px

  add_element_item_classes: ($el, item) ->
    class_names = item.class_names
    return if ember.isBlank(class_names)
    $el.addClass ember.makeArray(class_names).join(' ')

  add_draggable_class:    ($el) -> $el.addClass(@draggable_class)
  remove_draggable_class: ($el) -> $el.removeClass(@draggable_class)

  # ### Called after an item edit action. # ###

  clear_item_itemable: (item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve()  if ( ember.isBlank(item.itemable_id) and ember.isBlank(item.itemable_type) and ember.isBlank(item.itemable_value_path) )
      oitem = ember.merge({}, item)  # copy the original item with the itemable values for 'is_used'
      delete(item.itemable_id)
      delete(item.itemable_type)
      delete(item.itemable_value_path)
      @clear_itemable_is_used_unless_used_by_another_item(oitem).then =>
        resolve()