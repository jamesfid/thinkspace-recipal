import ember          from 'ember'
import ns             from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  tvo: ember.inject.service()

  # ###
  # ### Component Paths.
  # ###

  c_list_test_only:          ns.to_p 'indented_list', 'list', 'layout', 'shared', 'test_only'
  c_list_header:             ns.to_p 'indented_list', 'list', 'layout', 'shared', 'header'
  c_list_all_visible:        ns.to_p 'indented_list', 'list', 'layout', 'shared', 'all_visible'
  c_list_new_top:            ns.to_p 'indented_list', 'list', 'layout', 'shared', 'new_top'
  c_list_new_bottom:         ns.to_p 'indented_list', 'list', 'layout', 'shared', 'new_bottom'
  c_list_source_observation: ns.to_p 'indented_list', 'list', 'source', 'observation'
  c_list_source_mechanism:   ns.to_p 'indented_list', 'list', 'source', 'mechanism'
  c_response_item_show:      ns.to_p 'indented_list', 'response', 'item', 'show'

  init: ->
    @_super()
    @register_validation()
    @register_remove_itemable()

  register_validation: -> @get('tvo.status').register_validation('indented_list', @, 'validate_indented_list')

  register_remove_itemable: ->
    section = @get_indented_list_source_section()
    return if ember.isBlank(section)  # no source itemables, so don't need to register
    @get('tvo.helper').register @,
      section: 'remove_itemable'
      actions:   
        remove: 'remove_itemable_in_items'

  remove_itemable_in_items: (itemable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      # @get_response_manager().clear_itemable_from_all_items(itemable).then => resolve()
      @get_response_manager().remove_items_with_itemable(itemable).then => resolve()

  get_response_manager: -> @get 'response_manager'
  get_list_container:   -> @$('.indented-list_list-container')

  willInsertElement: ->
    $list_container = @get_list_container()
    @get_response_manager().register_list_container @, $list_container
    @add_background_grid()
    indent = @get_response_manager().indent_px + 400
    $list_container.css('min-height', "#{indent}px")

  add_background_grid: ->
    rm     = @get_response_manager()
    px     = rm.get('indent_px')
    ycolor = 'lightgrey'
    xcolor = 'white'
    grid   = "linear-gradient(to right, #{ycolor} 1px, transparent 1px), linear-gradient(to bottom, #{xcolor} 1px, transparent 1px)"
    $list_container = @get_list_container()
    $list_container.css 'background-size', "#{px}px #{px}px"
    $list_container.css 'background-image', grid

  get_indented_list_attributes:     -> @get('tvo.hash.indented_list_attributes') or {}
  get_indented_list_source_section: -> @get_indented_list_attributes().source
  get_response_manager_items:       -> @get_response_manager().value_items
