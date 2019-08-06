import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  # ###
  # ### Dragula to Re-Order Observations.
  # ###

  init_dragula: ->
    return if @get('viewonly')
    return if @get('attributes.sortable')  == 'false'  # check if template has <component ... sortable='false'/>
    return if @get('attributes.droppable') == 'false'  # backward compatibility for 'sortable' <component ... droppable='false'/>
    container_class  = @get('container_class')
    container        = @$(".#{container_class}")[0]
    @draggable_class = ember.guidFor(@) + '-gu-draggable'
    options          = 
      revertOnSpill:   true
      direction:       'veritcal'
      draggable_class: @draggable_class
      drop_container:  container
      moves:           @dragula_moves
      accepts:         @dragula_accepts
      copy:            @dragula_copy
    @drake = dragula(options)
    @drake.containers.push(container)
    @drake.component = @
    @init_drake_events(options)

  init_drake_events: (options) ->
    @drake.on 'drop', @dragula_drop

  # ###
  # ### Dragula Options Callbacks: @ = options.
  # ###

  # ### Whether an element can be dragged.
  dragula_moves: (el, source, handle, sibling) ->
    $el = $(el)
    $el.hasClass(@draggable_class)

  # ### Whether the 'target' container will accept a dragged item.
  dragula_accepts: (el, target, source, sibling) -> @drop_container == target

  # ### Whether the dragged item should be a copy or the item itself.
  dragula_copy: (el, source) -> false

  # ###
  # ### Dragula Event Callbacks: @ = drake.
  # ###

  dragula_drop: (el, target, source, sibling) ->
    @component.handle_dragula_drop(el, target, source, sibling)

