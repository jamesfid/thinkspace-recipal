import ember       from 'ember'
import totem_scope from 'totem/scope'
import tc          from 'totem/cache'
import ta          from 'totem/ds/associations'
import tm          from 'totem-messages/messages'
import val_mixin   from 'totem/mixins/validations'

# ### Parts
import reviews     from 'thinkspace-peer-assessment/managers/evaluation/reviews'
import user_data   from 'thinkspace-peer-assessment/managers/evaluation/user_data'
import balance     from 'thinkspace-peer-assessment/managers/evaluation/balance'
import qualitative from 'thinkspace-peer-assessment/managers/evaluation/qualitative'

export default ember.Object.extend val_mixin, reviews, user_data, balance, qualitative,
  # ### Services
  casespace: ember.inject.service()

  # ### Properties
  component: null # PhaseComponent that is rendered
  model:     null # peer_assessment/assessment model

  team:             null
  has_team_members: null
  reviewables:      null
  review_set:       null
  reviews:          null
  reviewable:       null
  review:           null

  # ### Computed properties
  is_confirmation:     ember.computed.equal 'reviewable', 'confirmation'
  is_read_only:        ember.computed.or 'totem_scope.is_read_only', 'review_set.is_read_only'
  is_review_read_only: ember.computed.or 'review.is_not_approvable'
  is_disabled:         ember.computed.or 'has_errors', 'is_read_only' # Also accounts for errors.
  has_errors:          ember.computed.equal 'isValid', false

  # #### Misc computed properties
  phase_settings: ember.computed.reads 'casespace.phase_settings'

  # ### Observers

  # When the phase settings change, update the review so back/forward work in the browser.
  # => reviewable_id changes in the phase settings (query param), adjust accordingly.
  phase_settings_observer: ember.observer 'phase_settings', ->
    @totem_messages.show_loading_outlet message: 'Changing teammate...'
    @set_review_from_phase_settings().then =>  
        @totem_messages.hide_loading_outlet()

  reviewable_observer: ember.observer 'reviewable', ->
    @get_reviewable_from_phase_settings().then (reviewable) =>
      current_reviewable = @get 'reviewable'
      # Only set the phase settings if it is a new reviewable.
      return if reviewable == current_reviewable
      @set_reviewable_phase_settings() if ember.isPresent(reviewable)

  # ### Events
  init: ->
    @_super()
    @totem_scope    = totem_scope
    @tc             = tc
    @totem_messages = tm
    @is_debug       = true

  # ### Submission
  submit: ->
    @validate().then (valid) =>
      return unless valid
      review_set = @get 'review_set'
      @debug "Submitting review set: ", review_set
      query = 
        id:     review_set.get('id')
        action: 'submit'
        verb:   'PUT'

      @totem_messages.show_loading_outlet()
      @tc.query(ta.to_p('tbl:review_set'), query, single: true).then =>
        @totem_messages.hide_loading_outlet()
        @totem_messages.api_success source: @, model: review_set, action: 'submit', i18n_path: ta.to_o('tbl:review_set', 'submit')
        @get('casespace').transition_to_current_assignment()

  # ### Helpers
  debug: (message, args...) ->
    console.log "[tbl:evaluation_manager] #{message}", args if @is_debug

  # ### Validations
  validations:
    points_different:
      numericality:
        'if': 'is_balance_and_points_different'
        greaterThanOrEqualTo: 2
        messages:
          greaterThanOrEqualTo: 'Not all evaluations can have the same score.'

    points_remaining:
      numericality:
        'if': 'is_balance'
        greaterThanOrEqualTo: 0
        lessThanOrEqualTo:    0
        messages:             
          greaterThanOrEqualTo: 'You cannot have negative points.'
          lessThanOrEqualTo: 'You must spend all of your points.'

    valid_qual_sections:
      presence:
        message: 'You must have inputs for all qualitative sections.'
