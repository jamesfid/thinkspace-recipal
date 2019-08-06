import ember from 'ember'
import ns    from 'totem/ns'
import path_manager   from 'thinkspace-diagnostic-path/path_manager'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName:           'li'
  classNames:        ['diag-path_list-item']
  classNameBindings: ['model.is_mechanism:diag-path_list-item-mechanism']
  attributeBindings: ['model_id']
  model_id:          ember.computed -> @get('model.id')

  c_path_item:                 ns.to_p 'diagnostic_path', 'path_item', 'show'  # for recursive path items
  c_path_item_edit:            ns.to_p 'diagnostic_path', 'path_item', 'edit'
  c_path_item_confirm_destroy: ns.to_p 'diagnostic_path', 'path_item', 'confirm_destroy'

  overflown_selector: '.diag-path_list-item-value'
  check_overflow:     ember.observer 'model.itemable.value', ->  ember.run.next => @set_overflown()

  edit_visible:            false
  confirm_destroy_message: null

  is_expanded:  false
  is_overflown: false
  is_collapsed: false

  collapsed_change: ember.observer 'all_collapsed', -> @set 'is_collapsed', @get('all_collapsed')

  actions:
    edit:   ->
      @sendAction 'parent_cancel'
      @set 'confirm_destroy_message', null
      @set 'edit_visible', true  unless @get('is_view_only')

    cancel: -> @set 'edit_visible', false

    toggle_collapse: ->
      @sendAction 'toggle_collapse', @
      @toggleProperty 'is_collapsed'
      return

    toggle_expand: ->
      @sendAction 'toggle_expand', @
      @toggleProperty 'is_expanded'
      return

    add_item: ->
      @sendAction 'parent_cancel'
      path_manager.add_first_nested_path_item @get('model'), description: "pi(#{@get('model.id')}) : my new path item"

    remove_item: ->
      @sendAction 'parent_cancel'
      @set 'edit_visible', false
      children = path_manager.all_path_item_children @get('model')
      count    = children.get('length')
      if count > 0
        @set 'confirm_destroy_message',  "Do you want to delete this item AND the (#{count}) #{(count > 1 and 'items') or 'item'} nested under it?"
      else
        @send 'destroy_path_item'

    destroy_path_item: ->
      path_manager.destroy_path_item @get('model')
      @send 'destroy_cancel'

    destroy_cancel: -> @set 'confirm_destroy_message', null

    parent_cancel: ->
      @set 'confirm_destroy_message', null
      @set 'edit_visible', false
      @sendAction 'parent_cancel'  # resend action to any parents up the chain

  set_overflown: ->
    selector = @get 'overflown_selector'
    $value   = @$(selector)
    return unless ember.isPresent($value)
    element  = $value[0]
    return unless element
    @set 'is_overflown', element.scrollWidth > element.clientWidth

  # TODO: Does this need to be => vs. ->?
  sortable_dragend: (event) ->
    console.log "Path Item sortable dragend called.", event
    event.preventDefault()
    event.stopPropagation()
    event.is_collapsed = @get('is_collapsed')
    component = ember.get(event, 'dropped_container.options.component')
    component.dragend_move_diagnostic_path_items(event)

  didInsertElement: -> path_manager.set_path_itemable_is_used @get('model'), true
