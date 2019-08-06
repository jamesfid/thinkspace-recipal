import ember          from 'ember'
import ns             from 'totem/ns'
import ajax           from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  assessment:  null
  review_sets: null
  color:       null

  notification: null

  is_expanded:  false
  is_notifying: false

  # ### Computed properties
  review_set:  ember.computed 'review_sets', 'model', ->
    review_sets = @get 'review_sets'
    user_id     = parseInt @get 'model.id'
    return unless ember.isPresent(review_sets) and ember.isPresent(user_id)
    review_sets.findBy('ownerable_id', user_id)

  review_set_state: ember.computed 'review_set.state', ->
    review_set = @get 'review_set'
    return 'Has not submitted any assessments' unless ember.isPresent(review_set)
    review_set.get('state')

  is_approvable: ember.computed 'review_set.state', 'review_set', ->
    review_set = @get 'review_set'
    return false unless ember.isPresent(review_set)
    review_set.get 'is_approvable'

  css_style: ember.computed 'color', ->
    color = @get 'color'
    return '' unless ember.isPresent(color)
    css   = ''
    css  += "border-bottom-color: ##{color};"
    css  += "border-top-color: ##{color};"
    new ember.Handlebars.SafeString css

  dropdown_collection: ember.computed 'model', ->
    review_set = @get 'review_set'
    collection = []
    unless ember.isEmpty(review_set) or @get('review_set.is_sent')
      collection.pushObject {display: 'Approve', action: 'approve'}      
    collection

  # ### Components
  c_review_set:            ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'review_set'
  c_state:                 ns.to_p 'casespace', 'case_manager', 'assignment', 'peer_assessment', 'state'
  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'

  # ### Events
  willInsertElement: ->
    @get('review_set') # Update the property since it won't be called in template, needed for notification.
    $modal = @$('.ts-tblpa_user-modal')
    $modal.attr('id', @get_modal_id())

  # ### Helpers
  state_change: (state) ->
    review_set = @get 'review_set'
    query      = 
      id:     review_set.get 'id'
      action: state
      verb:   'PUT'
    @tc.query(ns.to_p('tbl:review_set'), query, single: true)

  get_modal_id: -> "#{@elementId}-ts-tblpa_user-modal"
  get_modal:    -> $("##{@get_modal_id()}")
  show_modal:   -> @get_modal().foundation('reveal', 'open')
  close_modal:  -> @get_modal().foundation('reveal', 'close')

  set_is_notifying:   -> @set 'is_notifying', true
  reset_is_notifying: -> @set 'is_notifying', false

  actions:
    toggle:            -> @toggleProperty('is_expanded')
    approve:           -> @state_change('approve')
    unapprove:         -> @state_change('unapprove')
    ignore:            -> @state_change('ignore')
    approve_all:       -> @state_change('approve_all')
    unapprove_all:     -> @state_change('unapprove_all')
    notify:            ->  @show_modal()
    send_notification: ->
      notification  = @get 'notification'
      model         = @get 'model'
      user_id       = @get 'model.id'
      assessment_id = @get 'assessment.id'
      return unless user_id and assessment_id
      query        = 
        id:           assessment_id
        user_id:      user_id
        action:       'notify'
        notification: notification
        verb:         'POST'
      @totem_messages.show_loading_outlet()
      @tc.query(ns.to_p('tbl:assessment'), query, single: true).then =>
        @totem_messages.api_success source: @, model: model, action: 'notify', i18n_path: ns.to_o('tbl:assessment', 'notify')
        @totem_messages.hide_loading_outlet()
        @set 'notification', null
        @close_modal()
    close_notification_modal: -> 
      @close_modal()
