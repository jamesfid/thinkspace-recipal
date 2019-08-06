import ember       from 'ember'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  init_manager: (options={}) ->
    @init_maps()
    @init_readonly(options)
    @init_manager_properties(options)
    @init_drake(options)  unless @readonly
    @init_value_items()

  init_maps: ->
    @item_to_component     = ember.Map.create()  # item-hash to component
    @el_id_to_component    = ember.Map.create()  # element id (e.g. component guid) to component
    @new_source_containers = ember.Map.create()  # new item source containers

  init_readonly: (options) ->
    @readonly   = (options.readonly == true)
    @updateable = not @readonly

  init_manager_properties: (options) ->
    @store = totem_scope.get_store()
    @init_model(options)
    @init_containers(options)
    @init_draggable(options)
    @set_indent_px                    options.indent_px  or @default_indent_px()
    @set_max_indent                   options.max_indent or @default_max_indent()
    @set_zoom_level                   options.zoom_level or @default_zoom_level()
    @set_confirm_remove          not (options.confirm_remove == false)
    @set_send_response_to_server not (options.save_response == false)
    @queued_saves = []
    @save_error   = false

  init_model: (options) ->
    response = options.model
    @error "Required 'options.model' is blank."  if ember.isBlank(response)
    @response = response

  init_containers: (options) ->
    @list_container = null

  init_draggable: (options) ->
    @draggable_classes        = ember.makeArray(options.draggable or @default_draggable_class())
    @draggable_class          = @draggable_classes.join(' ')
    selectors                 = @draggable_classes.map (class_name) -> ".#{class_name}"
    @draggable_selector       = selectors.join(', ')
    options.draggable_classes = @draggable_classes  # set for dragula options callbacks

  init_drake: (options) ->
    options.revertOnSpill    = true
    options.direction        = 'veritcal'
    options.moves            = @moves
    options.copy             = @copy
    options.accepts          = @accepts
    options.response_manager = @
    @drake                   = dragula(options)
    @drake.response_manager  = @
    @init_drake_events(options)

  init_drake_events: (options) ->
    @drake.on 'drop',    @drop
    @drake.on 'cloned',  @cloned
    @drake.on 'cancel',  @cancel
    @drake.on 'shadow',  @shadow
    @drake.on 'drag',    @drag
    @drake.on 'dragend', @dragend

  init_value_items: (items) ->
    @value_items = (@response.get('value.items') or []).sortBy('pos_y')
