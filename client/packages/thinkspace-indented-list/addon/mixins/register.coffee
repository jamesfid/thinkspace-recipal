import ember  from 'ember'

export default ember.Mixin.create

  register_component: (component) ->
    item  = @get_component_item(component)
    el_id = @get_component_element_id(component)
    @el_id_to_component.set(el_id, component)
    @item_to_component.set(item, component)

  register_list_container: (component, list_container) ->
    return if ember.isBlank(list_container)
    @list_container_component = component
    @set_list_container(list_container)

  # ### Callback_fn should be the string name of the component's callback function.
  register_source_container: (component, source_container, options={}) ->
    return if ember.isBlank(source_container)
    @add_source_container(source_container)
    container = $(source_container)[0]
    @new_source_containers.set container,
      component:   component
      item_values: options.item_values or null
      callback_fn: options.callback or null

  get_component_item:       (component) -> component.get('item')
  get_component_element_id: (component) -> component.get('elementId')
