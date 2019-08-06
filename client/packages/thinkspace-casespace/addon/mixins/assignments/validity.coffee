import ember from 'ember'
import ta    from 'totem/ds/associations'
import ns    from 'totem/ns'

export default ember.Mixin.create
  # This relies on `model` being present as an Assignment record.
  has_phase_errors: ember.computed.or 'has_inactive_peer_assessments', 'model.has_inactive_phases', 'model.has_phases_without_team_set'

  # Assessments
  # In order to determine if an assignment is truly valid, it must check the assessments.
  has_inactive_peer_assessments: ember.computed 'model', 'assessments', 'assessments.@each.state', ->
    assessments = @get('assessments')
    return false unless ember.isPresent(assessments)
    states = assessments.mapBy('state')
    states.contains('neutral')

  assessments: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      query =
        id:                 @get('model.id')
        action:             'phase_componentables'
        componentable_type: ns.to_p('tbl:assessment')
      @tc.query(ns.to_p('assignment'), query, payload_type: ns.to_p('tbl:assessment')).then (assessments) =>
        resolve(assessments)
    ta.PromiseArray.create promise: promise

  actions:
    activate_assessments: ->
      return unless @get('assessments.length') > 0
      confirm = window.confirm('Are you sure you want to activate this evaluation?  You will not be able to make changes to the evaluation or teams once this is done.')
      return unless confirm
      @totem_messages.show_loading_outlet()
      promises = []
      @get('assessments').forEach (assessment) =>
        promise = @tc.query(ns.to_p('tbl:assessment'), {id: assessment.get('id'), action: 'activate', verb: 'PUT'}, single: true)
        promises.pushObject(promise)
        ember.RSVP.all(promises).then =>
          @totem_messages.hide_loading_outlet()
          @totem_messages.api_success source: @, model: assessment, action: 'activate', i18n_path: ns.to_o('tbl:assessment', 'activate')
