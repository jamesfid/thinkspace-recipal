import ember       from 'ember'
import tc          from 'totem/cache'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  # ###
  # ### Changes to the Itemables e.g. removed
  # ###

  # Do not remove the item but clear the item's itemable values and set the item.description to the component's show value.
  clear_itemable_from_all_items: (itemable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if ember.isBlank(itemable) or @readonly
      itemable_id   = parseInt(itemable.get 'id')
      itemable_type = totem_scope.get_record_path(itemable)
      save          = false
      @value_items.forEach (item) =>
        id   = item.itemable_id
        type = item.itemable_type
        if ember.isPresent(id) and ember.isPresent(type)
          if itemable_id == id and itemable_type == totem_scope.rails_polymorphic_type_to_path(type)
            save = true
            comp = @get_item_component(item)
            desc = if comp then comp.get('show_value') else ''
            delete(item.itemable_id)
            delete(item.itemable_type)
            delete(item.itemable_value_path)
            item.description = desc
      @save_response()  if save
      resolve()

  # Remove the items associated with the itemable.
  # Either remove just the item or remove the item all 'packed' children.
  remove_items_with_itemable: (itemable, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if ember.isBlank(itemable) or @readonly
      itemable_id   = parseInt(itemable.get 'id')
      itemable_type = totem_scope.get_record_path(itemable)
      remove_items  = []
      @value_items.forEach (item) =>
        id   = item.itemable_id
        type = item.itemable_type
        if ember.isPresent(id) and ember.isPresent(type)
          if itemable_id == id and itemable_type == totem_scope.rails_polymorphic_type_to_path(type)
            remove_items.push(item)
      return resolve() if ember.isBlank(remove_items)
      if options.remove_packed_children == true
        @remove_items_itemable_and_packed_children(remove_items)
      else
        @remove_only_items_with_itemable(remove_items)
      resolve()

  remove_only_items_with_itemable: (items) ->
    items.map (item) =>
      prev_item        = @get_prev_item(item)
      children_visible = @are_item_children_visible(item)
      children         = @get_item_children(item)
      index            = @value_items.indexOf(item)
      @value_items.removeAt(index)
      @set_children_items_visibility(children, true)  unless children_visible
      @reset_has_children(prev_item)  if prev_item
    @save_response()

  remove_items_itemable_and_packed_children: (items) -> items.map (item) => @remove_item(item)  # call remove_item action for each item
