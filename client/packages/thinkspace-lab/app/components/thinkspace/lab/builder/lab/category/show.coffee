import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  is_category_active: ember.computed 'admin.selected_category', -> @get('model') == @get('admin.selected_category')

  category_dropdown_collection: ember.computed ->
    [
      {display: @t('builder.lab.admin.edit_category'),   action: 'category_edit'}
      {display: @t('builder.lab.admin.delete_category'), action: 'category_delete'}
    ]

  result_new_dropdown_collection: ember.computed ->
    [
      {display: @t('builder.lab.admin.new_result'),          action: 'result_new', type: 'result'}
      {display: @t('builder.lab.admin.new_adjusted_result'), action: 'result_new', type: 'adjusted_result'}
      {display: @t('builder.lab.admin.new_html_result'),     action: 'result_new', type: 'html_result'}
    ]

  sort_by:          ['position']
  sorted_results:   ember.computed.sort 'category_results', 'sort_by'
  category_results: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      category = @get('model')
      category.get(ns.to_p 'lab:results').then (results) =>
        resolve(results)
    ta.PromiseArray.create promise: promise

  actions:
    category_edit:   -> @get('admin').set_action_overlay('c_category_edit')
    category_delete: -> @get('admin').set_action_overlay('c_category_delete')

    result_new: (params) ->
      admin = @get('admin')
      admin.set 'new_result_type', params.type
      admin.set_action_overlay('c_result_new')

  # ###
  # ### Sortable.
  # ###

  element_id:        -> @get('elementId')
  sortable_selector: -> @get('admin').get_result_sortable_selector() + ".#{@element_id()}"

  didInsertElement: -> @add_result_sortable()

  willDestroyElement: ->
    selector = @sortable_selector()
    @$(selector).sortable('destroy')

  add_result_sortable: ->
    selector = @sortable_selector()
    options  = 
      group:             "results_#{@element_id()}"
      containerSelector: selector
      itemPath:          '> tbody'
      itemSelector:      'tr'
      placeholder:       '<tr class="placeholder"/>'
      clone:             false
      consume:           false
      exclude:           '.sortable-exclude'
      nested:            false
      vertical:          true
      drag:              true
      drop:              true
      delay:             100
      pullPlaceholder:   false
      onDrop:            @on_drop
      component:         @
    @$(selector).sortable(options)

  on_drop: ($item, container, _super, event) ->
    _super($item, container, _super, event)
    component = container and container.options and container.options.component
    return unless component
    admin   = component.get('admin')
    results = component.get('category_results')
    admin.on_drop_result_reorder(component: component, notify: 'category_results')
