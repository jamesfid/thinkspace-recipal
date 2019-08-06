import ember from 'ember'
# Mixins to build response manager.
import m_config          from './mixins/configuration'
import m_dragula         from './mixins/dragula'
import m_handle_events   from './mixins/handle_events'
import m_helpers         from './mixins/helpers'
import m_initialize      from './mixins/initialize'
import m_register        from './mixins/register'
import m_save_response   from './mixins/save_response'
import m_item_actions    from './mixins/item/actions'
import m_item_change     from './mixins/item/change'
import m_item_component  from './mixins/item/component'
import m_item_helpers    from './mixins/item/helpers'
import m_item_itemable   from './mixins/item/itemable'
import m_item_new        from './mixins/item/new'
import m_item_selected   from './mixins/item/selected'
import m_itemable_change from './mixins/item/itemable_change'

export default ember.Object.extend(
    m_initialize,
    m_config,
    m_dragula,
    m_handle_events,
    m_helpers,
    m_register,
    m_save_response,
    m_item_actions,
    m_item_change,
    m_item_component,
    m_item_helpers,
    m_item_itemable,
    m_item_new,
    m_item_selected,
    m_itemable_change,
  )
