import ember  from 'ember'
import config from './config/environment'
import tr     from 'totem/config/routes'

Router = ember.Router.extend
  location: config.locationType or '/users/sign_in'

Router.map -> tr.map(@)

export default Router
