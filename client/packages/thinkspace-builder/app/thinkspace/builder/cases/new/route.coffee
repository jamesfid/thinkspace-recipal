import ember      from 'ember'
import ns         from 'totem/ns'
import auth_mixin from 'simple-auth/mixins/authenticated-route-mixin'
import base       from 'thinkspace-base/base/route'

export default base.extend auth_mixin,
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  titleToken: 'New'

  model: (params) ->
    space_id = params.space_id
    @tc.find_record(ns.to_p('space'), space_id)

  afterModel: (model) -> 
    assignment = @store.createRecord ns.to_p('assignment'),
      'thinkspace/common/space': model
    assignment.save().then (assignment) =>
      @transitionTo ns.to_r('builder', 'cases', 'details'), assignment
