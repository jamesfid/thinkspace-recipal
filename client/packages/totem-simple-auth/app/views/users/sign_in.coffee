import ember from 'ember'
import config from 'totem/config'

export default ember.View.extend
  templateName: config.simple_auth and config.simple_auth.sign_in_template
 
  keyPress: -> @get('controller.totem_messages').clear_all()