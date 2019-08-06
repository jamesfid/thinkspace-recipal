import ember            from 'ember'
import ns               from 'totem/ns'
import base_component   from 'thinkspace-base/components/base'

export default base_component.extend

  get_response_manager: -> @get 'response_manager'
  get_list_container:   -> @get_response_manager().$list_container

  send_response_to_server: true
  confirm_remove:          false
  indent_px:               20
  zoom_level:              ember.computed.reads 'response_manager.zoom_level'

  willInsertElement: ->
    rm = @get_response_manager()
    @set_indent_px                 rm.indent_px  # init as-is
    rm.set_confirm_remove          @get('confirm_remove')
    rm.set_send_response_to_server @get('send_response_to_server')

  actions: 
    toggle_save:           -> @get_response_manager().set_send_response_to_server @toggleProperty('send_response_to_server')
    toggle_confirm_remove: -> @get_response_manager().set_confirm_remove          @toggleProperty('confirm_remove')

    indent_px_10: -> @indent_px_action(10)
    indent_px_20: -> @indent_px_action(20)
    indent_px_30: -> @indent_px_action(30)
    indent_px_40: -> @indent_px_action(40)
    indent_up:    -> @indent_px_action @incrementProperty('indent_px')
    indent_down:  -> @indent_px_action @decrementProperty('indent_px')

    zoom_in:  -> @zoom_action(1)
    zoom_out: -> @zoom_action(-1)

    # TODO: Would be best to trigger on a window resize (in the response_manager or another component).
    reset_overflow: -> @reset_overflow()

  indent_px_action: (px) ->
    if px < 5
      px = 5
      @set 'indent_px', px
    @set_indent_px(px)
    @add_background_grid()
    rm = @get_response_manager()
    rm.value_items.forEach (item) =>
      comp = rm.get_item_component(item)
      comp.set_indent()

  zoom_action: (offset) ->
    rm = @get_response_manager()
    rm.set_zoom_level @get_zoom_level(offset)
    @reset_overflow()

  get_zoom_level: (offset) ->
    zoom_level    = @get 'zoom_level'
    default_level = @get_response_manager().default_zoom_level()
    plus          = offset > 0
    switch
      when zoom_level >= 8 and plus     then default_level
      when zoom_level <= 1 and not plus then default_level
      else zoom_level + offset

  set_indent_px: (px) ->
    @get_response_manager().set_indent_px(px)
    @set 'indent_px', px
    @$('.indent-px').css('background-color', '#bcbcbc')
    @$(".px-#{px}").css('background-color', '#63b4d6')

  add_background_grid: ->
    ipx = @get_response_manager().indent_px
    px  = ipx - 1
    $list_container = @get_list_container()
    $list_container.css 'background-size', "#{px}px #{px}px"
    $list_container.css 'background-image', 'linear-gradient(to right, lightgrey 1px, transparent 1px), linear-gradient(to bottom, lightgrey 1px, transparent 1px)'

  reset_overflow: ->
    rm = @get_response_manager()
    rm.value_items.forEach (item) =>
      comp = rm.get_item_component(item)
      comp.set_has_overflow()
