import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  calculated_overview: null # Anonymized result from the server.
  assessment:          null

  # ### Components
  c_overview_type: ns.to_p 'tbl:overview', 'type', 'base'

  # ### Events
  init: ->
    @_super()
    @set_user_data().then => @set_assessment().then => @set 'all_data_loaded', true

  # ### Helpers
  set_user_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @overview_ajax('review', 'reviews').then (payload) =>
        console.log "[tbl:overview] Payload returned as: ", payload
        resolve(payload)

  overview_ajax: (type, sub_action, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @get_overview_query(sub_action, options)
      ajax.object(query).then (payload) =>
        @set 'calculated_overview', payload
        resolve(payload)

  set_assessment: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get 'model'
      model.get('tbl:assessment').then (assessment) =>
        @set 'assessment', assessment
        resolve()

  get_overview_query: (sub_action, options={}) ->
    overview        = @get 'model'
    query           = @totem_scope.get_view_query(overview, sub_action: sub_action)
    query.verb      = 'get'
    query.model     = overview
    query.data      = options.data or {}
    query.data.auth = query.auth # Workaround since ajax.object expects data to contain the params.
    @totem_scope.add_authable_to_query(query)
    query