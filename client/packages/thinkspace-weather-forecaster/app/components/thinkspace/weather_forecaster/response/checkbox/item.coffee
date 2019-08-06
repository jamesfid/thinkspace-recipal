import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  is_checked: ember.computed 'input_values.[]', ->
    values = @get('input_values') or []
    id     = @get_id()
    id and values.contains(id)

  has_score:        ember.computed.reads 'model.has_score'
  is_correct_class: ember.computed 'is_checked', ->
    switch
      when not @get('has_score')                  then null
      when @get('model').id_is_correct(@get_id()) then 'correct'
      when @get('is_checked')                     then 'incorrect'
      else null

  get_id: -> @get('response_id')

  actions:
    toggle_checkbox: ->
      return if @get('is_view_only')
      id = @get_id()
      if @get('is_checked')
        @sendAction 'uncheck', id
      else
        @sendAction 'check', id
