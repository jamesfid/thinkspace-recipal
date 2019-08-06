import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['ts-componentable']

  # ### Properties
  all_collapsed:    false

  # ### Components
  c_path_item: ns.to_p 'diagnostic_path_viewer', 'path_item', 'show'

  # ### Observers
  tse_after_render: ember.observer 'model.ownerable_top_level_path_items.length', ->
    ember.run.schedule 'afterRender', @, =>
      @tse_resize()

  actions:
    toggle_collapse_all: ->
      @toggleProperty('all_collapsed')
      @tse_resize()
      return

    toggle_collapse: (c_path_item) ->
      @tse_resize()

    toggle_expand: (c_path_item) ->
      @tse_resize()