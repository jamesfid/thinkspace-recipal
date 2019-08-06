import ember from 'ember'
import ns    from 'totem/ns'

import ds from 'ember-data'
# import base_component from 'thinkspace-base/components/base'

export default ember.Component.extend
  tagName: ''

  c_response: ember.computed ->
    metadata = @get('item.response_metadata') or {}
    switch metadata.type
      when 'input'     then ns.to_p 'wf:response', 'input'
      when 'radio'     then ns.to_p 'wf:response', 'radio'
      when 'checkbox'  then ns.to_p 'wf:response', 'checkbox'
      else
        ns.to_p 'wf:response', 'error'

  item_header:  ember.computed -> @get_assessment_item_or_item_value('item_header')
  presentation: ember.computed -> @get_assessment_item_or_item_value('presentation')
  help_tip:     ember.computed -> @get('model.help_tip') or @get('item.help_tip')
  metadata:     ember.computed -> @get 'item.response_metadata'
  has_help_tip: ember.computed.bool 'help_tip'

  get_assessment_item_or_item_value: (prop) ->
    value = @get("model.#{prop}") or @get("item.#{prop}")
    value and value.htmlSafe()

  actions:
    show_help:     -> @sendAction 'show_help', @get('help_tip')
    save: (values) -> @sendAction 'save', @get('response'), values

  has_score:        ember.computed.reads 'response.has_score'
  is_correct_class: ember.computed 'has_score', ->
    return null unless @get('has_score')
    (@get('response.is_correct') and 'correct') or 'incorrect'

  item:     null
  response: null

  didInsertElement: ->
    forecast        = @get('forecast')
    assessment_item = @get('model')
    assessment_item.get(ns.to_p 'wf:item').then (item) =>
      forecast.response_for_assessment_item(assessment_item).then (response) =>
        unless response
          response = forecast.store.createRecord(ns.to_p 'wf:response')
          response.set_associations(forecast, assessment_item)
        @set 'response', response
        @set 'item', item