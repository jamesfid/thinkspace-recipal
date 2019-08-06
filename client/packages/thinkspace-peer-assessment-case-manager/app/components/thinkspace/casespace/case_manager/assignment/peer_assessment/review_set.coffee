import ember from 'ember'
import ns from 'totem/ns'
import ajax from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  tagName:      ''
  is_expanded: false
  assessment:  null

  reviews_sort_by: ['reviewable.sort_name:asc']
  sorted_reviews:  ember.computed.sort 'model.reviews', 'reviews_sort_by'

  css_style: ember.computed 'color', ->
    color = @get 'color'
    return '' unless ember.isPresent(color)
    css   = ''
    css  += "border-left-color: ##{color};"
    css  += "border-top-color: ##{color};"
    new ember.Handlebars.SafeString css

    "border-left-color: ##{color}; border-top-color: ##{color}"
  # Components
  c_review: ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'review'

  actions:
    approve: ->
      console.log "[tbl-pa-cm] Approving review SET: ", @get 'model'
      query =
        model:  @get 'model'
        id:     @get 'model.id'
        action: 'approve'
        verb:   'put'

      ajax.object(query).then (payload) =>
        review_set = ajax.normalize_and_push_payload 'tbl:review_set', payload, single: true