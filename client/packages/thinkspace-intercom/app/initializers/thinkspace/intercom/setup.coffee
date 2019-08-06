import ember  from 'ember'
import ns     from 'totem/ns'
import tm     from 'totem/mixins'
import config from 'totem/config'

initializer = 
  name:  'thinkspace-intercom-setup'
  after: ['totem', 'simple-auth']

  initialize: (container, app) ->
    return if ember.isBlank(config.crisp_app_id)
    # application controller mixin
    tm.add 'controllers/application', ns.to_m('intercom', 'controller')
    
    # casespace toolbar mixin
    tm.add ns.to_c('casespace', 'toolbar'), ns.to_m('intercom', 'toolbar')


export default initializer
