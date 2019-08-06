import ember          from 'ember'
import ns             from 'totem/ns'
import ta             from 'totem/ds/associations'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['indented-list']

  tvo: ember.inject.service()

  c_response_items: ns.to_p 'indented_list', 'response', 'items'
  
  init: ->
    @_super()
    @set_responses().then =>
      @set('is_ready', true)

  set_responses: ->
    new ember.RSVP.Promise (resolve, reject) =>
      list       = @get('model')
      path       = ns.to_p('indented:responses')
      @get('tvo.helper').load_ownerable_view_records(list).then =>       
        responses = list.get('responses')
        @create_response() if ember.isBlank(responses) and @totem_scope.get('view_user_is_current_user')
        resolve()

  create_response: ->
    store    = @totem_scope.get_store()
    list     = @get('model')
    response = store.createRecord ns.to_p('indented:response'),
      ownerable_id:   @totem_scope.get_ownerable_id()
      ownerable_type: @totem_scope.get_ownerable_type()
      value:          
        items: []
    response.set ns.to_p('indented:list'), list
    response
