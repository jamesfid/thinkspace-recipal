import ember from 'ember'
import tvo   from 'totem-template-manager/services/template_value_object'

initializer = 
  name:  'totem-template-manager'
  after: ['totem']

  initialize: (container, app) ->

    app.register 'service:tvo', tvo

export default initializer
