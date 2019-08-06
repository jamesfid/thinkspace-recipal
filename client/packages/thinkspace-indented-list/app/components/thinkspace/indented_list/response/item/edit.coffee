import ember from 'ember'
import ns from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  edit_value: null

  willInsertElement: -> 
    @get('response_manager').get_item_value(@get 'item').then (value) =>
      @set 'edit_value', value

  actions:
    cancel: -> @sendAction 'cancel'
    done:   -> @sendAction 'done', @get('edit_value')
