import ember from 'ember'
# Mixins to build question manager.
import m_helpers    from './mixins/qm/helpers'
import m_initialize from './mixins/qm/initialize'
import m_rooms      from './mixins/qm/rooms'
import m_status     from './mixins/qm/status'
import m_values     from './mixins/qm/values'

export default ember.Object.extend(
    m_initialize,
    m_values,
    m_rooms,
    m_status,
    m_helpers,
  )
