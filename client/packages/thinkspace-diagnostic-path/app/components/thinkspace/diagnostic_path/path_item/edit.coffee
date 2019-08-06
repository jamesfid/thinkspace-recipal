import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  className: 'sortable-exclude'

  value:       null
  placeholder: 'What did you observe?'

  has_path_itemable:  ember.computed.bool 'model.path_itemable_id'

  edit_path_itemable: ember.computed 'has_path_itemable', ->
    @get('has_path_itemable') and true  # TODO: Base 'true' value on a path connfiguration???

  didInsertElement: ->
    if @get('has_path_itemable')
      @get('model.path_itemable').then (itemable) =>
        @set 'value', itemable.get('value')
        @set_textarea()
    else
      @set 'value', @get('model.description')
      @set_textarea()

  set_textarea: ->
    $textarea = @$('textarea')
    $textarea.focus()

  actions:
    cancel: -> @sendAction 'cancel'

    done: ->
      path_item = @get('model')
      value     = @get('value')
      if @get('edit_path_itemable')
        @save_path_itemable(path_item, value)
      else
        @save_path_item(path_item, value)
      @send 'cancel'

  save_path_itemable: (path_item, value) ->
    path_item.get('path_itemable').then (itemable) =>
      console.warn 'save path itemable:', value, itemable
      itemable.set 'value', value
      itemable.save().then (itemable) =>
        @totem_messages.api_success source: @, model: itemable, action: 'save', i18n_path: ns.to_o('observation', 'save')
      , (error) =>
        @totem_messages.api_failure error, source: @, model: itemable, action: 'save'

  save_path_item: (path_item, value) ->
    console.warn 'save path item:', value, path_item, @
    path_item.set 'path_itemable_id', null
    path_item.set 'path_itemable_type', null
    path_item.set 'description', value
    path_item.save().then (path_item) =>
      @totem_messages.api_success source: @, model: path_item, action: 'save', i18n_path: ns.to_o('path_item', 'save')
    , (error) =>
      @totem_messages.api_failure error, source: @, model: path_item, action: 'save'

