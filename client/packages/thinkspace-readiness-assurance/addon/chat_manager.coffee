import ember from 'ember'
# Mixins to build question manager.
import m_helpers    from './mixins/cm/helpers'
import m_initialize from './mixins/cm/initialize'
import m_values     from './mixins/cm/values'

export default ember.Object.extend(
    m_initialize,
    m_values,
    m_helpers,
  )
