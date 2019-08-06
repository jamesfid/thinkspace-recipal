import ember            from 'ember'
import ns               from 'totem/ns'
import base_component   from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Services
  casespace: ember.inject.service()
  
  # ### Properties
  token: null # Token from the ReportToken to get access to a Report.

  # ### Components
  c_loader: ns.to_p 'common', 'loader'

  # ### Routes
  r_assignments_reports: ns.to_p 'assignments', 'reports'

  init: ->
    @_super()
    @get_report().then => @set_all_data_loaded()

  # ### Getters
  get_report: ->
    new ember.RSVP.Promise (resolve, reject) =>
      token = @get 'token'
      return unless ember.isPresent(token) # TODO: Raise a totem error?
      query = 
        action: 'access'
        verb:   'get'
        id:     token

      @tc.query(ns.to_p('reporter:report'), query, single: true).then (report) =>
        @set 'model', report
        resolve()