import ember from 'ember'
import ns    from 'totem/ns'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,

  casespace: ember.inject.service()

  afterModel: (assignment) ->
    @get('casespace').set_current_models(assignment: assignment).then =>
      @totem_messages.hide_loading_outlet()
