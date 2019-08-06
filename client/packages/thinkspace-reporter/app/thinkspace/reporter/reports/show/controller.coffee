import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  # ### Properties
  token: null # Set by setupController, the ReportToken's token.

  # ### Components
  c_report: ns.to_p 'reporter', 'report'
