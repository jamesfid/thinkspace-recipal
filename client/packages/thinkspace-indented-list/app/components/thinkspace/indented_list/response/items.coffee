import ember            from 'ember'
import ns               from 'totem/ns'
import response_manager from 'thinkspace-indented-list/response_manager'
import base_component   from 'thinkspace-base/components/base'

export default base_component.extend
  indent_px: 20

  c_response_item_show: ns.to_p 'indented_list', 'response', 'item', 'show'

  c_list_layout: ember.computed ->
    layout = @get('list.layout')
    ns.to_p 'indented_list', 'list', 'layout', layout

  willInsertElement: ->
    @totem_data.ability.refresh().then =>
      readonly = @get('list.expert') or @get('viewonly')
      rm = response_manager.create()
      rm.init_manager
        model:     @get('model')
        indent_px: @get('indent_px')
        readonly:  readonly
      @set 'response_manager', rm
