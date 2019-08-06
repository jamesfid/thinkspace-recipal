import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  get_container:        -> $('ol.obs-list_list')
  get_response_manager: -> @get('response_manager')

  willInsertElement: -> @get_response_manager().register_source_container @, @get_container(), callback: 'set_new_item_values'

  set_new_item_values: ($el, new_item) ->
    new ember.RSVP.Promise (resolve, reject) =>
      rm          = @get_response_manager()
      item_values = rm.get_source_element_html_model_attributes($el)
      if ember.isBlank(item_values.itemable_value_path)
        item_values.itemable_value_path = 'value'
      rm.get_item_itemable(item_values).then (observation) =>
        return resolve(item_values) if ember.isBlank(observation)
        observation.get(ns.to_p 'list').then (list) =>
          return resolve(item_values)  if ember.isBlank(list)
          category_id      = list.get('category_id')
          item_values.icon = @convert_observation_list_category_to_icon_id(category_id)
          resolve(item_values)

  convert_observation_list_category_to_icon_id: (category_id) ->
    switch category_id
      when 'd'      then 'lab'
      when 'h'      then 'html'
      when 'm'      then 'mechanism'
      else null

