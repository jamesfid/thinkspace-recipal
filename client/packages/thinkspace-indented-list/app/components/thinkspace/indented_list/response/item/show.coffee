import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames:        ['indented-list_item-container']
  classNameBindings: ['zoom_level_class', 'item_visible::indented-list_hide', 'is_selected:indented-list_selected-item', 'overflow_visible:overflow-visible', 'overflow_visible:is-expanded', 'edit_visible:is-editing', 'confirm_remove_visible:is-deleting', 'is_mechanism:is-mechanism']
  attributeBindings: ['tabindex']

  c_response_item_edit:           ns.to_p 'indented_list', 'response', 'item', 'edit'
  c_response_item_confirm_remove: ns.to_p 'indented_list', 'response', 'item', 'confirm_remove'
  c_dropdown_split_button:        ns.to_p 'common', 'dropdown_split_button'

  # ### Computed properties
  is_mechanism:     ember.computed.equal 'item.icon', 'mechanism'
  zoom_level_class: ember.computed 'response_manager.zoom_level', -> "zoom-#{@get('response_manager.zoom_level')}"
  show_dropdown:    ember.computed.or 'has_overflow', 'has_children', 'response_manager.updateable'

  dropdown_collection: ember.computed 'has_children', 'has_overflow', 'children_visible', 'overflow_visible', ->
    overflow_text = if @get('overflow_visible') then 'Collapse' else 'Expand'
    pack_text     = if @get('children_visible') then 'Pack with children' else 'Unpack children'
    collection    = []
    collection.push {display: overflow_text, action: 'toggle_overflow'}  if @get('has_overflow')
    collection.push {display: pack_text,     action: 'toggle_children'}  if @get('has_children')
    if @get('response_manager.updateable')
      collection.push {display: 'Edit',                action: 'edit'}
      collection.push {display: 'Duplicate before',    action: 'duplicate_before'}
      collection.push {display: 'Duplicate after',     action: 'duplicate_after'}
      collection.push {display: 'Add path item above', action: 'insert_before'}
      collection.push {display: 'Add path item below', action: 'insert_after'}
      collection.push {display: 'Remove',              action: 'remove'}
    collection

  item_visible:     true
  children_visible: true
  has_children:     false
  number_children:  null
  is_selected:      false

  show_value:             null
  edit_visible:           false
  confirm_remove_visible: false

  tabindex: 1

  get_element:          -> @$()
  get_item:             -> @get('item')
  get_response_manager: -> @get('response_manager')

  turn_on_edit:    -> @set 'edit_visible', true
  turn_off_edit:   -> @set 'edit_visible', false
  turn_on_remove:  -> @set 'confirm_remove_visible', true
  turn_off_remove: -> @set 'confirm_remove_visible', false

  # ###
  # ### Events.
  # ###

  # In order to receive the 'keyUp' event, this item's element must have focus.
  click: (event) ->
    return if @get('edit_visible')
    @get_response_manager().select_item @get_item()
    @highlight_itemable()

  focusOut: (event) ->
    @set 'is_selected', false
    @unhighlight_itemable()

  focusIn: (event) ->
    return if @get('edit_visible')
    @get_response_manager().select_item @get_item(), skip_focus: true
    @highlight_itemable()

  # event.keyCodes
  #  37:  left arrow
  #  38:  up arrow
  #  39:  right arrow
  #  40:  down arrow
  #  61:  '+' above '='
  #  107: '+' on numeric keypad
  #  109: '-' on numeric keypad
  #  173: '-' by '='
  keyDown: (event) ->
    return if @get('edit_visible')
    switch event.keyCode
      when 37           then @get_response_manager().move_left  @get_item(); @stop_event(event)
      when 38           then @get_response_manager().move_up    @get_item(); @stop_event(event)
      when 39           then @get_response_manager().move_right @get_item(); @stop_event(event)
      when 40           then @get_response_manager().move_down  @get_item(); @stop_event(event)
      when 46           then @send 'remove'; @stop_event(event)

  keyPress: (event) ->
    return if @get('edit_visible')
    char_code = event.which || event.charCode || event.keyCode
    return unless char_code
    value = String.fromCharCode(char_code).toLowerCase()

    switch value
      when 'q' then @insert_before(); @stop_event(event)
      when 'w' then @insert_after(); @stop_event(event) 
      when 'a' then @duplicate_before(); @stop_event(event)
      when 's' then @duplicate_after(); @stop_event(event)
      when 'z' then @send 'toggle_children'; @stop_event(event)

  stop_event: (event) ->
    event.preventDefault()
    event.stopPropagation()
  
  duplicate_before: -> @get_response_manager().duplicate_before @get_item()
  duplicate_after:  -> @get_response_manager().duplicate_after  @get_item();
  insert_before:    -> @get_response_manager().insert_before  @get_item()
  insert_after:     -> @get_response_manager().insert_after  @get_item()

  # ###
  # ### Actions.
  # ###
  actions:
    duplicate_before: -> @duplicate_before()
    duplicate_after:  -> @duplicate_after()
    insert_before:    -> @insert_before()
    insert_after:     -> @insert_after()

    remove: ->
      return if @get_readonly()
      if @get_response_manager().show_confirm_remove()
        @remove_draggable_class()
        @turn_off_edit()
        @turn_on_remove()
      else
        @send 'remove_ok'

    remove_cancel: ->
      @add_draggable_class()
      @turn_off_remove()

    remove_ok: ->
      @unhighlight_itemable()
      @get_response_manager().remove_item @get_item()

    edit: ->
      return if @get_readonly()
      @remove_draggable_class()
      @turn_off_remove()
      @turn_on_edit()

    edit_cancel: ->
      @add_draggable_class()
      @turn_off_edit()

    edit_done: (value) ->
      item = @get_item()
      rm   = @get_response_manager()
      if ember.isPresent(value)
        item.description = value.trimRight()
        # Set the item's itemable 'is_used' off unless another item also has the itemable.
        rm.clear_item_itemable(item).then =>
          @set_item_show_value()
          @set_has_overflow()
          rm.save_response()
      @send 'edit_cancel'

    toggle_overflow: ->
      @toggleProperty('overflow_visible')
      return

    toggle_children: ->
      return unless @get('has_children')
      items = @get_item_children()
      @get_response_manager().set_children_items_visibility items, @toggleProperty('children_visible')
      @set_number_of_children()

  set_number_of_children: ->
    return if @get('children_visible')
    @set 'number_children', @get_item_children(false).length

  # ###
  # ### Insert Element.
  # ###

  willInsertElement: ->
    @set_item_show_value()
    @set_itemable_is_used()
    @set_itemable_icon()
    @get_response_manager().register_component(@)

  didInsertElement: ->
    @add_draggable_class()
    @set_has_children()
    @add_item_classes()
    @set_indent()

    # ### TESTING ONLY
    @set 'guid', ember.guidFor(@)
    item = @get_item()
    unless ember.isPresent(item.test_id)
      ember.set(item, 'test_id', @get_response_manager().value_items.indexOf(item))

  # ###
  # ### Set Properties.
  # ###

  set_item_show_value: ->
    rm   = @get_response_manager()
    item = @get_item()
    rm.get_item_value(item).then (value) =>
      @set 'show_value', value

  set_has_children:       -> @set 'has_children', @get_response_manager().has_item_children @get_item()

  get_item_children:      (visible=true) -> @get_response_manager().get_item_children @get_item(), visible
  add_item_classes:       -> @get_response_manager().add_element_item_classes @get_element(), @get_item()
  set_itemable_is_used:   -> @get_response_manager().set_itemable_is_used @get_item()
  add_draggable_class:    -> @get_response_manager().add_draggable_class(@get_element())
  remove_draggable_class: -> @get_response_manager().remove_draggable_class(@get_element())
  get_readonly:           -> @get_response_manager().readonly

  itemable_icon: null
  set_itemable_icon: ->
    item = @get_item()
    icon = @get_response_manager().get_item_itemable_icon(item)
    @set 'itemable_icon', icon

  set_indent: ->
    item = @get_item()
    left = @get_response_manager().calc_item_indent(item)
    $el  = @get_element()
    $el.css('margin-left', left)
    #bc = @background_color(item.pos_x)  TESTING ONLY.
    #$el.css('background-color', bc) TESTING ONLY.
    @set_has_overflow()
    @set_indent_letter()

  background_color: (x) ->
    switch x
      when 0   then 'lightgray'
      when 1   then 'lightblue'
      when 2   then 'wheat'
      when 3   then 'lightgreen'
      when 4   then 'lightsalmon'
      when 5   then 'lightcoral'
      when 6   then 'lightpink'
      else @get_random_rgb(x)

  get_random_rgb: (x) ->
    min = 0
    max = 255
    r = Math.floor(Math.random()*(max-min+1)+min)
    g = Math.floor(Math.random()*(max-100+1)+100)
    b = Math.floor(Math.random()*(max-min+1)+min)
    "rgb(#{r},#{g},#{b})"

  # ###
  # ### Highlight Itemable (example only, may not want to do this).
  # ###

  itemable_highlight_class: 'indented-list_highlight-itemable'

  unhighlight_itemable: -> @get_itemable_element().removeClass @get('itemable_highlight_class')

  highlight_itemable: -> @get_itemable_element().addClass @get('itemable_highlight_class')

  get_itemable_element: ->
    item = @get_item()
    id   = item.itemable_id
    type = item.itemable_type
    return $(null) unless (type and id)
    path = @totem_scope.rails_polymorphic_type_to_path(type)
    $("[model_id='#{id}'][model_type='#{path}']")

  # ###
  # ###
  # ###
  # TODO: move to mixin (include action toggle_overflow)
  overflow_visible:  false
  has_overflow:      false

  set_overflow_visible_on:  -> @set 'overflow_visible', true
  set_overflow_visible_off: -> @set 'overflow_visible', false

  set_has_overflow: ->
    ember.run.schedule 'afterRender', @, =>
      $el        = @$().find('.overflow')
      element    = $el[0]
      return if ember.isBlank(element)
      @set 'has_overflow', element.scrollWidth > element.clientWidth
      @propertyDidChange('dropdown_collection') # Recompute to avoid a race condition, allows expand to show consistently.

  set_indent_letter: (indent) ->
    pos_x = parseInt @get_item().pos_x
    char  = String.fromCharCode(97 + pos_x)
    char  = 'ZZ' if pos_x > 25
    @set 'indent_letter', char.capitalize()
