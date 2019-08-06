import ember  from 'ember'
import ds     from 'ember-data'
import config from 'totem/config'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

export default ds.ActiveModelAdapter.extend
  namespace: 'api'
  host:      config.api_host

  coalesceFindRequests: true

  ajax: (url, type, hash={}) ->
    timeout      = config and config.ajax_timeout
    hash.timeout = timeout  if timeout
    @_super(url, type, hash)

  # findQuery looks for the query object keys 'action', 'id', and 'verb'.
  # They will be deleted from the query params base on:
  #  * If query contains both 'action' and 'id' then format the url for a :member request.
  #      e.g. base_url/id/action  #=> delete action and id from query
  #  * If query has an 'action' but no 'id' then format the url for a :collection request.
  #      e.g. base_url/action     #=> delete action from query
  #  * If query does not have an action (e.g. null) then get a standard buildURL (e.g. the null is ignored).
  #  * Always deletes the 'verb' key and either uses it in the buildURL or defaults to 'GET'.
  # Note: Latest ember-data buildURL will convert '/' to '%2F' so need to add the action after the url is built.
  findQuery: (store, type, query) ->
    totem_scope.find_query(type, query)  # add model type and id
    action = query.action
    id     = query.id
    verb   = query.verb or 'GET'
    url    = @buildURL(type.typeKey, id)
    url   += '/' + action if action
    delete(query.id)      if query.id
    delete(query.action)  if query.action
    delete(query.verb)    if query.verb
    @ajax(url, verb, { data: query })

  # Delete record does not go through the rest_serializer's 'serializeIntoHash' function
  # so the totem_scope information must be added in the rest_adapter.
  # Calls to 'totem_scope' add the authable/ownerable model type and id when appropriate.
  deleteRecord: (store, type, record) ->
    query = {}
    totem_scope.delete_record(type, record, query)
    id = record.get 'id'
    @ajax(@buildURL(type.typeKey, id), "DELETE", data: query);

  find: (store, type, id) ->
    query = {}
    totem_scope.find(type, id, query)
    @ajax(@buildURL(type.typeKey, id), 'GET', data: query);

  findAll: (store, type, sinceToken) ->
    query = {}
    query.since = sinceToken  if sinceToken
    totem_scope.find_all(type, query)
    @ajax(@buildURL(type.typeKey), 'GET', { data: query });

  findMany: (store, type, ids) ->
    query = {ids: ids}
    totem_scope.find_many(type, query)
    @ajax(@buildURL(type.typeKey, 'select'), 'GET', data: query)

  # Override this so that the 422 error does not get gobbled.
  ajaxError: (jqXHR, responseText, errorThrown) ->
    isObject = jqXHR != null and typeof jqXHR == 'object'
    if isObject
      jqXHR.then = null
      if !jqXHR.errorThrown
        if typeof errorThrown == 'string'
          jqXHR.errorThrown = new Error(errorThrown)
        else
          jqXHR.errorThrown = errorThrown
    jqXHR