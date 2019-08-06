import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  model:        null
  tag_count:    null
  all_selected: null

  library_tags:  ember.computed.reads 'model.all_tags'
  is_selected:   false

  c_checkbox: ns.to_p('common', 'shared', 'checkbox')

  all_selected_obs: ember.observer 'all_selected', ->
    if @get('all_selected')
      @set('is_selected', false)

  actions:
    toggle_selected: ->
      tag_name = @get('model.name')
      @toggleProperty('is_selected')
      @sendAction('click_action', tag_name)