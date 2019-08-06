import ember  from 'ember'

export default ember.Mixin.create

  # ###
  # ### Dragula Options Callbacks: @ = options.
  # ###

  # ### Response manager values may be set 'after' the drake was created with the options.
  # ### Options functions (e.g. moves, accepts, etc.) can reference values by using: @response_manager.prop-name
  # ###

  # ### Whether an element can be dragged.
  # ### Must have a class listed in the option 'draggable'.
  moves: (el, source, handle, sibling) ->
    $el = $(el)
    @draggable_classes.find (class_name) -> $el.hasClass(class_name)

  # ### Whether the 'target' container will accept a dragged item.
  # ### The 'list container' will accept any dragable items.
  accepts: (el, target, source, sibling) -> @response_manager.list_container == target

  # ### Whether the dragged item should be a copy or the item itself.
  # ### If the item is in the 'list container', do not make a copy, otherwise make a copy.
  copy: (el, source) -> @response_manager.list_container != source

  # ###
  # ### Dragula Event Callbacks: @ = drake.
  # ###

  # ### Triggered when the mirror (e.g. copy or clone).
  # ### This is the item being dragged to get the x-offset.
  cloned: (clone, original, type) ->
    @cloned_element = clone
    @cloned_item    = $(original).data('item')

  drop: (el, target, source, sibling) -> @response_manager.handle_drop(@cloned_element, el, target, source, sibling)

  cancel: (el, container, source) -> @response_manager.handle_cancel(@cloned_element, el, container, source)

  shadow: (el, original, source) ->
    $item       = $('.gu-mirror')
    if ember.isPresent($item)
      $transit    = $('.gu-transit')
      pos_x       = @response_manager.get_element_pos_x($item)
      margin_left = @response_manager.calc_item_indent({pos_x: pos_x})
      $transit.css('margin-left', margin_left + 'px')

  drag: (el, source) ->
    @is_dragging       = true
    $(document).mousemove (event) =>
      @response_manager.shadow.call(@, el, null, source)

  dragend: (el) ->
    if @is_dragging
      $(document).unbind('mousemove')
      @is_dragging = false