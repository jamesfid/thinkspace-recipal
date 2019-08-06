import ember  from 'ember'

export default ember.Mixin.create

  get_new_item: ($el, pos_x, source) ->
    new ember.RSVP.Promise (resolve, reject) =>
      new_item = 
        pos_y:       0
        pos_x:       pos_x
        description: null
      @get_source_container_item_values($el, source, new_item).then (item_values) =>
        ember.merge(new_item, item_values)  if @is_hash(item_values)
        resolve(new_item)

  get_source_container_item_values: ($el, source, new_item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      hash = @new_source_containers.get(source) or {}
      return resolve(hash.item_values)  if ember.isBlank(hash.callback_fn)
      @call_source_container_callback_function($el, hash, new_item).then (item_values) => resolve(item_values)

  call_source_container_callback_function: ($el, hash, new_item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      fn   = hash.callback_fn
      comp = hash.component
      return resolve(hash.item_values) unless ember.isPresent(comp) and @is_function(comp[fn])
      response = comp[fn]($el, new_item)
      if @is_object(response) and @is_function(response.then)
        response.then (item_values) => resolve(item_values)
      else
        resolve(response)

  get_source_element_html_model_attributes: ($el) ->
    values = {}
    id     = $el.attr('model_id')
    id     = parseInt(id)  if id
    type   = $el.attr('model_type')
    path   = $el.attr('model_value_path')
    values.itemable_id         = id    if id
    values.itemable_type       = type  if type
    values.itemable_value_path = path  if path
    values
