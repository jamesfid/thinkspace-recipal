import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Services
  builder: ember.inject.service()

  # ### Properties
  assessments: null

  # ### Events
  init: ->
    @_super()
    @set_assessments().then => @set_all_data_loaded()

  # ### Helpers
  set_assessments: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get('builder').get_assignment().then (assignment) =>
        query =
          id:                 assignment.get('id')
          action:             'phase_componentables'
          componentable_type: ns.to_p('tbl:assessment')
        @tc.query(ns.to_p('assignment'), query, payload_type: ns.to_p('tbl:assessment')).then (assessments) =>
          @set 'assessments', assessments
          resolve()
        , (error) => @error(error)
      , (error) => @error(error)
    , (error) => @error(error)

  set_assessment_on_model: (assessment) ->
    model = @get 'model'
    model.set 'assessment_id', assessment.id
    model.save().then (model) =>
      console.log "Saved model: ", model

  actions:
    select: (assessment) -> @set_assessment_on_model(assessment)
