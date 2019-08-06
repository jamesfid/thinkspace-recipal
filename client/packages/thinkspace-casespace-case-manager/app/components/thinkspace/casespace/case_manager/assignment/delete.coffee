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
    exit:   -> @get('wizard_manager').exit()
    delete: -> @delete_assignment()

  delete_assignment: ->
    assignment = @get('model')
    console.warn 'delete assignment', assignment.toString()
    query = 
      model:  assignment
      id:     assignment.get('id')
      action: 'delete'
      verb:   'delete'
    ajax.object(query).then =>
      @totem_messages.api_success source: @, model: assignment, action: 'delete', i18n_path: ns.to_o('assignment', 'delete')
      assignment.unloadRecord()
      @send 'exit'
    , (error) =>
      @totem_messages.hide_loading_outlet()
      @totem_messages.api_failure error, source: @, model: assignment, action: 'clone'    
