import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  wizard_manager: ember.inject.service()

  actions:
    exit:  -> @get('wizard_manager').exit()
    clone: -> @clone_space()

  clone_space: ->
    space = @get('model')
    @totem_messages.show_loading_outlet message: "Cloning #{space.get('title')}..."
    query = 
      model:  space
      id:     space.get('id')
      action: 'clone'
      verb:   'post'
    ajax.object(query).then (payload) =>
      index_route = @container.lookup("route:#{ns.to_p('spaces', 'index')}")
      index_route.refresh_spaces()
      @totem_messages.hide_loading_outlet()
      @totem_messages.api_success source: @, model: space, action: 'clone', i18n_path: ns.to_o('space', 'clone')
      @send 'exit'
    , (error) =>
      @totem_messages.hide_loading_outlet()
      @totem_messages.api_failure error, source: @, model: space, action: 'clone'    
