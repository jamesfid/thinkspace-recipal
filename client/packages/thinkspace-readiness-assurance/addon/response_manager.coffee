import ember from 'ember'
# Mixins to build response manager.
import m_chat           from './mixins/rm/chat'
import m_helpers        from './mixins/rm/helpers'
import m_initialize     from './mixins/rm/initialize'
import m_response       from './mixins/rm/response'
import m_rooms          from './mixins/rm/rooms'
import m_server_events  from './mixins/rm/server_events'
import m_status         from './mixins/rm/status'

export default ember.Object.extend(
    m_initialize,
    m_response,
    m_status,
    m_chat,
    m_rooms,
    m_server_events,
    m_helpers,
  )
