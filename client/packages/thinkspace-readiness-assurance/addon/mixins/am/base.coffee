# Mixins to build admin manager.
import ember     from 'ember'
import m_data    from './data'
import m_helpers from './helpers'
import m_init    from './initialize'
import m_irat    from './irat'
import m_menus   from './menus'
import m_msgs    from './messages'
import m_timers  from './timers'
import m_tracker from './tracker'
import m_trat    from './trat'

export default ember.Mixin.create(
  m_init,
  m_menus,
  m_irat,
  m_trat,
  m_data,
  m_timers,
  m_tracker,
  m_helpers,
  m_msgs,
)
