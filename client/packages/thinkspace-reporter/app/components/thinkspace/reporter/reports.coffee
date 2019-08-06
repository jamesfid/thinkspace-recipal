import ember            from 'ember'
import ns               from 'totem/ns'
import base_component   from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  casespace: ember.inject.service()

  # ### Properties
  is_report_requested: false

  # ### Computed properties
  current_assignment: ember.computed.reads 'casespace.current_assignment'

  # ### Components
  c_loader:    ns.to_p 'common', 'loader'
  c_report_tr: ns.to_p 'reporter:report', 'tr'

  # ### Events
  init: ->
    @_super()
    @get_reports().then => @set_all_data_loaded()

  # ### Getters
  get_reports: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('reporter:report')).then (reports) =>
        @set 'reports', reports
        resolve()

  # ### Helpers
  set_is_report_requested: -> @set 'is_report_requested', true

  actions:
    request_report: ->
      assignment = @get 'current_assignment'
      query      = 
        type:          'ownerable_data'
        verb:          'post'
        action:        'generate'
      @totem_scope.add_authable_to_query(query, assignment)
      @totem_messages.show_loading_outlet(message: 'Creating report...')
      @tc.query(ns.to_p('reporter:report'), query).then =>
        @set_is_report_requested()
        @totem_messages.hide_loading_outlet()