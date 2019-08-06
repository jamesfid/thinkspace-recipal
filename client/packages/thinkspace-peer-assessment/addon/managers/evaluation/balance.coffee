import ember       from 'ember'
import totem_scope from 'totem/scope'
import tc          from 'totem/cache'
import ta          from 'totem/ds/associations'
import tm          from 'totem-messages/messages'

# ###
# ### Balance points helpers
# ###

export default ember.Mixin.create
  # ### Computed properties
  model_points_different:          ember.computed.reads 'model.points_different'
  is_balance:                      ember.computed.reads 'model.is_balance'
  is_balance_and_points_different: ember.computed.and   'is_balance', 'model_points_different'

  # #### Points computed properties
  points_total: ember.computed 'model.points', 'reviewables', ->
    return unless @get('is_balance')
    points_per_member = @get 'model.points_per_member'
    reviewables       = @get 'reviewables.length' || 0
    points_per_member * reviewables

  points_remaining: ember.computed 'points_total', 'points_expended', ->
    return unless @get('is_balance')
    points_total    = @get 'points_total'
    points_expended = @get 'points_expended'
    points_total - points_expended

  points_expended: ember.computed 'reviews.@each.value', ->
    return unless @get('is_balance')
    reviews = @get 'reviews'
    return 0 unless ember.isPresent(reviews)
    points  = 0
    reviews.forEach (review) => points += review.get_expended_points()
    points

  points_different: ember.computed 'points_expended', ->
    return unless @get('is_balance')
    # At least two unique values must be present for the points (e.g. cannot have all team members the same).
    reviews = @get 'reviews' 
    return 0 unless ember.isPresent(reviews)
    return 0 if reviews.get('length') == 1 # Cannot be a points difference error.
    points  = []
    reviews.forEach (review) =>
      points.pushObject review.get_expended_points()
    points.uniq().get('length')

  has_negative_points_remaining: ember.computed 'points_remaining', ->
    points = @get 'points_remaining'
    points < 0
