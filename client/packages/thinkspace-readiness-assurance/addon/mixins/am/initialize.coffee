import ember from 'ember'
import ns    from 'totem/ns'
import rad   from 'thinkspace-readiness-assurance/base/admin/rad'

export default ember.Mixin.create

  pubsub: ember.inject.service()
  ttz:    ember.inject.service()
  ra:     ember.inject.service ns.to_p('ra')

  init: ->
    @_super()
    @pubsub   = @get('pubsub')
    @ttz      = @get('ttz')
    @ra       = @get('ra')
    @messages = @ra.get('messages')
    @store    = @get_store()
    @reset_data()
    @ra.join_admin_room()

  rad: (options={}) ->
    options.am = @
    rad.create(options)

  reset: ->
    @reset_data()

  toString: -> 'ReadinessAssuranceAdminManager'
