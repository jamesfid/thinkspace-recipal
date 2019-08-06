import ember from 'ember'
import ns    from 'totem/ns'
import ta    from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  admin: ember.inject.service(ns.to_p 'lab', 'admin')

  # ### Events
  init: ->
    @_super()
    @get('categories') # Trigger a fetch.

  # ### Components
  c_loader: ns.to_p 'common', 'loader'

  sort_by: ['position']
  sorted_categories: ember.computed.sort 'categories', 'sort_by'

  categories: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      admin = @get('admin')
      admin.load_chart().then =>
        admin.get_chart_categories().then (categories) =>
          admin.set_chart_selected_category().then =>
            @set_all_data_loaded()
            resolve(categories)
    ta.PromiseArray.create promise: promise

  actions:
    category_new: -> @get('admin').set_action_overlay('c_category_new')

    exit: -> @get('admin').exit()
