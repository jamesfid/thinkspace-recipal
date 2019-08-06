import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Controller.extend
  # ### Properties
  token: null # Passed in from controller, it is the reference to a ReportToken
  
  # ### Components
  c_reporter_report:      ns.to_p 'reporter', 'report'