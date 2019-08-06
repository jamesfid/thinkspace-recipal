import ember          from 'ember'
import ns             from 'totem/ns'
import ta             from 'totem/ds/associations'
import ajax           from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  classNames: ['indented-list']

  c_response_items: ns.to_p 'indented_list', 'response', 'items'

  responses: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      sub_action = @get('sub_action') or null
      if sub_action == 'expert'
        @send_responses_ajax_request('indented:expert_response', sub_action).then (responses) =>
          resolve(responses)
        , (error) =>
          @totem_messages.api_failure error, source: @, model: @get('model')
      else
        sub_action = 'user' if ember.isBlank(sub_action)
        @send_responses_ajax_request('indented:response', sub_action).then (items) =>
          response = @create_response(items)
          resolve([response])
        , (error) =>
          @totem_messages.api_failure error, source: @, model: @get('model')
    ta.PromiseArray.create promise: promise

  send_responses_ajax_request: (type, sub_action) ->
    new ember.RSVP.Promise (resolve, reject) =>
      list        = @get('model')
      query       = @totem_scope.get_view_query(list, sub_action: sub_action)
      query.data  = {auth: query.auth}
      query.model = list
      ajax.object(query).then (payload) =>
        return resolve(payload)  if sub_action == 'user'
        records = ajax.normalize_and_push_payload(type, payload)
        resolve(records)
      , (error) => reject(error)

  create_response: (items) ->
    store    = @totem_scope.get_store()
    list     = @get('model')
    response = store.createRecord ns.to_p('indented:response'),
      ownerable_id:   @totem_scope.get_ownerable_id()
      ownerable_type: @totem_scope.get_ownerable_type()
      value:          
        items: items
    response.set ns.to_p('indented:list'), list
    response
