import ember from 'ember'
import ds from 'ember-data'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'
# import default_prop_mixin from 'cnc-base/mixins/default_property_settings'
# import validations from 'totem/mixins/validations'

export default base_component.extend

  ## Content is the AmGraph
  content:         null

  start_humidity:  null
  start_temp:      null
  start_dew_point: null

  cloud_base:      null

  final_temp:      null
  final_humidity:  null
  final_dew_point: null

  parent_action:   null

  color:           null
  
  trial_num: ember.computed 'content', ->
    content = @get('content')

    for key, value of content
      return key

  style: ember.computed 'color', 'is_visible', ->
    color      = @get('color')
    is_visible = @get('is_visible')

    if color?
      if is_visible
        return "border: 2px solid #{color}; border-radius:2px; margin-bottom:.15em;"
      else
        return "border: 2px solid black; border-radius:2px; margin-bottom:.15em;"

  is_visible: true

  didInsertElement: ->
    content = @get('content')

    for key, value of content
      start_humidity  = parseFloat(value['start_humidity']).toFixed(1)
      start_temp      = parseFloat(value['start_temp']).toFixed(1)
      start_dew_point = parseFloat(value['start_dew_point']).toFixed(1)
      final_temp      = parseFloat(value['final_temp']).toFixed(1)
      final_humidity  = parseFloat(value['final_humidity']).toFixed(1)
      final_dew_point = parseFloat(value['final_dew_point']).toFixed(1)
      cloud_base      = value['cloud_base']
      color           = value['color']

      @set('start_humidity',  start_humidity)
      @set('start_temp',      start_temp)
      @set('start_dew_point', start_dew_point)
      @set('final_temp',      final_temp)
      @set('final_humidity',  final_humidity)
      @set('final_dew_point', final_dew_point)
      @set('color',           color)

      if cloud_base == 'Clear'
        @set('cloud_base', cloud_base)
      else
        @set('cloud_base', parseFloat(cloud_base).toFixed(1))

  actions:
    parent_action: ->
      @toggleProperty('is_visible')
      is_visible = @get('is_visible')
      trial_num = @get('trial_num')
      @sendAction('parent_action', is_visible, trial_num)
    