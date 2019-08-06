import ember          from 'ember'
import totem_error    from 'totem/error'

export default ember.Mixin.create

  get_element_item:      ($el) -> @get_element_component($el).get('item')
  get_element_component: ($el) -> @el_id_to_component.get($el.attr 'id')

  get_item_component: (item) -> @item_to_component.get(item)
  get_item_element:   (item) ->
    comp = @get_item_component(item)
    comp and comp.$()

  # If the sibling is the list end class, ignore it.
  # An empty div at the end of the list is needed to avoid the issue where Ember loses track of the DOM fragment
  # picked up by Dragula.  This could be replicated by changing the pos_x of the last item, then trying to place an item below it.
  # This would not render correctly as Ember seemingly loses track of the original DOM fragment.  The value_items was always correctly in sync.
  get_sibling: (sibling) ->
    $sibling = $(sibling)
    if $sibling.hasClass(@default_list_end_class()) then null else sibling

  get_minimum_pos_x: -> @value_items.mapBy('pos_x').sort().shift() or 0

  set_item_pos_x: (item, pos_x) -> ember.set(item, 'pos_x', pos_x)
  set_item_pos_y: (item, pos_y) -> ember.set(item, 'pos_y', pos_y)
  set_items_pos_y: (items)      -> items.forEach (item, index) => @set_item_pos_y(item, index)

  is_jquery_object: (obj) -> obj and jQuery and (obj instanceof(jQuery))

  is_function: (fn) -> typeof(fn) == 'function'

  is_object: (obj) -> obj and typeof(obj) == 'object'

  is_hash: (obj) -> @is_object(obj) and not ember.isArray(obj)

  debug_items: (items) ->
    msg = []
    msg.push "Items:#{items.length} ->"
    items.map (item) => msg.push "[y:#{item.pos_y} id:#{item.itemable_id}]"
    console.info msg.join(', ')

  stringify: (obj) -> JSON.stringify(obj)

  error: (message='') -> totem_error.throw @, message

  toString: -> 'ResponseManager'
