import ember from 'ember'
import ns    from 'totem/ns'
import path_manager from 'thinkspace-diagnostic-path/path_manager'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName:    'li'
  path:       null
  classNames: ['diag-path_list-item-mechanism', 'diag-path_list-item']

  didInsertElement: ->
    @$('.diag-path_mechanism-list').sortable
      group:     'path-obs-list'
      clone:     true
      consume:   true
      exclude:   '.sortable-exclude'
      component: @
      drop:      false


  sortable_dragend: (event) ->
    event.preventDefault()
    event.stopPropagation()
    component = ember.get(event, 'dropped_container.options.component')
    $item     = event.dragged_item
    component.dragend_new_mechanism(event)
