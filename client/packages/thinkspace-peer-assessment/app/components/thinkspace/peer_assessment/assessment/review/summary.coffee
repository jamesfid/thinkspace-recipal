import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: 'li'

  expended_points:       ember.computed 'model', ->   @get('model').get_expended_points()
  positive_comments:     ember.computed 'model', ->   @get('model').get_positive_qualitative_comments()
  constructive_comments: ember.computed 'model', ->   @get('model').get_constructive_qualitative_comments() 

  assessment_quantitative_items: ember.computed 'assessment', -> @get('assessment.quantitative_items')
  category_responses:            ember.computed 'assessment_quantitative_items', ->
    items = @get 'assessment_quantitative_items'
    return [] unless ember.isPresent(items)
    review = @get 'model'
    ids    = items.mapBy('id')
    responses = []
    ids.forEach (id) =>
      value             = review.get_quantitative_value_for_id(id)
      label             = items.findBy('id', id).label
      response          = {}
      response['id']    = id
      response['value'] = value
      response['label'] = label
      responses.pushObject(response)
    responses

  # Action names
  edit_team_member: 'edit_team_member'

  actions:
    edit_team_member: -> 
      @get('model.reviewable').then (reviewable) =>
        @get('manager').set_reviewable reviewable