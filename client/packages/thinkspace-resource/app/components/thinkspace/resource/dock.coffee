import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace/components/dock_base'

export default base.extend

  casespace: ember.inject.service()

  c_pane: ns.to_p 'resource', 'pane'

  resource_model:       ember.computed.reads 'casespace.current_model'
  can_manage_resources: ember.computed.bool  'resource_model.can.manage_resources'
  show_resources:       ember.computed.or    'resource_model.has_resources', 'can_manage_resources'

  actions:
    close: -> @addon_visible_off()
    exit:  -> @addon_visible_off()  # override base dock

  # Override base dock functionality to prevent registering as an active addon.
  # Resources do not modify the ownerable, so do not need to handle as a full addon
  # and regenerate the current phase.
  set_active_addon: -> return
