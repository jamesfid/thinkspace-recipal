import ember  from 'ember'

export default ember.Mixin.create

  default_item_description: -> 'No description added.'
  default_draggable_class:  -> 'gu-draggable'
  default_indent_px:        -> 20
  default_max_indent:       -> 25
  default_zoom_level:       -> 3
  default_list_end_class:   -> 'gu-list-end'

  set_indent_px:               (px) -> @indent_px = px
  set_max_indent:              (n)  -> @max_indent = n
  set_confirm_remove:          (tf) -> @confirm_remove = tf
  set_send_response_to_server: (tf) -> @send_response_to_server = tf
  set_zoom_level:              (zl) -> @set 'zoom_level', zl  # use 'set' to trigger any observers

  # ### List container
  set_list_container: (container) ->
    @error "Cannot set the list container after it has already been set."  if ember.isPresent(@list_container)
    @list_container  = if @is_jquery_object(container) then container[0] else container
    @$list_container = $(@list_container)
    @add_source_container(container)

  # ### Use 'register_source_container' to add new items based on an item-values template or callback.
  add_source_container: (containers) ->
    return if @readonly
    source_containers = if @is_jquery_object(containers) then containers.toArray() else ember.makeArray(containers)
    for container in source_containers
      @drake.containers.push(container) unless @drake.containers.contains(container)
