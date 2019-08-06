import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

# Note: Using the diagnostic-path styles so side-by-side views have the same spacing.
export default base_component.extend
  tagName:           'li'
  classNames:        ['diag-path_list-item']
  classNameBindings: ['model.is_mechanism:diag-path_list-item-mechanism']

  c_path_item: ns.to_p 'diagnostic_path_viewer', 'path_item', 'show'

  overflown_selector: '.diag-path_list-item-value'
  check_overflow:     ember.observer 'model.itemable.value', ->  ember.run.next => @set_overflown()

  collapsed_change: ember.observer 'all_collapsed', -> @set 'is_collapsed', @get('all_collapsed')

  is_collapsed: false
  is_expanded:  false
  is_overflown: false

  set_overflown: ->
    selector = @get 'overflown_selector'
    $value   = @$(selector)
    return unless ember.isPresent($value)
    element  = $value[0]
    return unless element
    @set 'is_overflown', element.scrollWidth > element.clientWidth

  actions:
    toggle_collapse: ->
      @toggleProperty 'is_collapsed'
      return

    toggle_expand: ->
      @toggleProperty 'is_expanded'
      return
