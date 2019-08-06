import ember from 'ember'
import base  from 'totem/components/base'
import totem_data_mixin from 'totem/mixins/data'
import common_helper from 'thinkspace-base/mixins/common_helper'
export default base.extend totem_data_mixin, common_helper,
  # ### Properties
  all_data_loaded: false

  get_store: -> @container.lookup('store:main')

  # ### Data helpers
  set_all_data_loaded:   -> @set 'all_data_loaded', true
  reset_all_data_loaded: -> @set 'all_data_loaded', false

  totem_data_config: ability: true, metadata: true

  transitionToRoute: (args...) -> @container.lookup('controller:application').transitionToRoute(args...)

  current_user: ember.computed -> @totem_scope.get('current_user')
