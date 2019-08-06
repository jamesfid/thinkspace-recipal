import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-peer-assessment/components/peer_assessment/overview/type/base'

export default base.extend
  # ### Properties from `base`
  # model:               null # Ember `tbl:overview` model
  # calculated_overview: null # Server-generated anonymized overview object
  # assessment:          null

  assessment_quantitative_items: ember.computed 'assessment', -> @get('assessment.quantitative_items')
  categories:                    ember.computed 'assessment_quantitative_items', ->
    items = @get 'assessment_quantitative_items'
    return [] unless ember.isPresent(items)
    ids    = items.mapBy('id')
    responses = []
    ids.forEach (id) =>
      label             = items.findBy('id', id).label
      response          = {}
      response['id']    = id
      response['value'] = @get_calculated_overview_value_for_id(id)
      response['label'] = label
      responses.pushObject(response)
    responses

  overview_score: ember.computed 'calculated_overview.quantitative', ->
    overview = @get 'calculated_overview'
    return null unless ember.isPresent(overview)
    quantitative = ember.get(overview, 'quantitative')
    return 0 unless ember.isPresent(quantitative)
    for id, score of quantitative
      return score

  get_calculated_overview_value_for_id: (id) ->
    calculated_overview = @get('calculated_overview')
    return null unless ember.isPresent(calculated_overview)
    quantitative = calculated_overview['quantitative']
    return null unless ember.isPresent(quantitative)
    id = parseInt(id)
    quantitative[id]