# Mixins to build service.
import ember     from 'ember'
import m_events  from 'thinkspace-casespace/mixins/services/server_events/events'
import m_helpers from 'thinkspace-casespace/mixins/services/server_events/helpers'
import m_init    from 'thinkspace-casespace/mixins/services/server_events/initialize'
import m_rooms   from 'thinkspace-casespace/mixins/services/server_events/rooms'

export default ember.Mixin.create(
  m_init,
  m_rooms,
  m_events,
  m_helpers,
)

