import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''   # needed since horizontal li

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  is_category_active: ember.computed 'admin.selected_category', -> @get('model') == @get('admin.selected_category')

  actions:
    select_category: (category) ->
      admin = @get('admin')
      admin.clear()
      admin.set_selected_category(category)

  # ###
  # ### Sortable.
  # ###

  sortable_selector: -> @get('admin').get_category_sortable_selector()

  didInsertElement: -> @add_category_sortable()

  willDestroyElement: ->
    selector = @sortable_selector()
    $(selector).sortable('destroy')

  add_category_sortable: ->
    selector = @sortable_selector()
    options =
      group:             'categories'
      containerSelector: selector
      handle:            '.ts-lab_admin-sortable-category-handle'
      clone:             false
      consume:           false
      exclude:           '.sortable-exclude'
      nested:            false
      vertical:          false
      drag:              true
      drop:              true
      delay:             5
      pullPlaceholder:   false
      onDrop:            @on_drop
      admin:             @get('admin')
    $(selector).sortable(options)

  on_drop: ($item, container, _super, event) ->
    _super($item, container, _super, event)
    admin = container and container.options and container.options.admin
    return unless admin
    admin.on_drop_category_reorder($item, container)
