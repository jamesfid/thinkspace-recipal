import ember from 'ember'
import tm from 'totem-messages/messages'

initializer = 
  name:       'totem-messages'
  after:      ['totem']
  initialize: (container, app) ->

    tm.set_container(container)

    app.register('totem:messages', tm, instantiate: false)
    app.inject('controller', 'totem_messages', 'totem:messages')
    app.inject('route', 'totem_messages', 'totem:messages')
    app.inject('component', 'totem_messages', 'totem:messages')

export default initializer
