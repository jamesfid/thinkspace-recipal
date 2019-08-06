import ember  from 'ember'
import ns     from 'totem/ns'
import m_base from 'totem-messages/mixins/services/messages/base'

export default ember.Service.extend m_base,

  message_model_type: ns.to_p('casespace', 'message')
  message_load_url:   'thinkspace/pub_sub/server_events/load_messages'
