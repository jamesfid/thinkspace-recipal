import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace-case-manager/routes/base'

export default base.extend
  titleToken: (model) -> 'Clone ' + model.get('title')

  model: (params) -> @get_updatable_spaces()

  afterModel: (model) -> @set_current_models(assignment: model).then => @load_assignment()

  get_updatable_spaces: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @load_spaces().then =>
        @get_assignment_from_params(params).then =>
          resolve @get('case_manager').get_updatable_store_spaces()
      , (error) =>
        reject(error)
    , (error) =>
      reject(error)
