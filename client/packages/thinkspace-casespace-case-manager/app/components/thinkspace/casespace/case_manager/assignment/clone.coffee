import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # Services
  wizard_manager: ember.inject.service()
  case_manager:   ember.inject.service()

  current_space: ember.computed.reads 'case_manager.current_space'

  clone_spaces: ember.computed ->
    cm     = @get('case_manager')
    space  = @get('current_space')
    cm.get_store_spaces().without(space).sortBy('title')

  actions:
    exit: -> @get('wizard_manager').exit()

    clone: (space_id) -> @clone_assignment(space_id)

  clone_assignment: (space_id) ->
    assignment = @get('model')
    @totem_messages.show_loading_outlet message: "Cloning #{assignment.get('title')}..."
    query = 
      model:  assignment
      id:     assignment.get('id')
      action: 'clone'
      verb:   'post'
      data:
        space_id: space_id
    ajax.object(query).then (payload) =>
      new_assignment = ajax.normalize_and_push_payload 'assignment', payload, single: true
      assignment.store.pushPayload(payload)
      @totem_messages.hide_loading_outlet()
      @totem_messages.api_success source: @, model: new_assignment, action: 'clone', i18n_path: ns.to_o('assignment', 'clone')
      @send 'exit'
    , (error) =>
      @totem_messages.hide_loading_outlet()
      @totem_messages.api_failure error, source: @, model: assignment, action: 'clone'    
