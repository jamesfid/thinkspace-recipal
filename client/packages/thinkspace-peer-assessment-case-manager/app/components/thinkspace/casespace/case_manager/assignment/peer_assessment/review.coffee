import ember          from 'ember'
import ns             from 'totem/ns'
import ajax           from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  tagName:     ''
  is_expanded: false

  # ### Computed properties
  css_style: ember.computed 'color', ->
    color = @get 'color'
    return '' unless ember.isPresent(color)
    css   = ''
    css  += "border-left-color: ##{color};"
    css  += "border-top-color: ##{color};"
    new ember.Handlebars.SafeString css

  is_approvable: ember.computed.reads 'model.is_approvable'

  # ### Components
  c_review_comment:        ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'review', 'comment'
  c_review_qual_item:      ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'review', 'qualitative'
  c_state:                 ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'state'
  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'

  # Events
  willInsertElement: ->
    approved = @get 'model.is_approved'
    @set 'is_expanded', true unless approved

  # ### Helpers
  state_change: (state) ->
    model = @get 'model'
    query = 
      id:     model.get 'id'
      action: state
      verb:   'PUT'
    @tc.query(ns.to_p('tbl:review'), query, single: true)

  actions:
    toggle: -> @toggleProperty 'is_expanded'
    set_qualitative_comment_value: (id, type, value) ->
      console.log "[tbl-pa-cm] Setting with id, type, value: ", id, type, value
      review = @get 'model'
      review.set_qualitative_value id, type, value
      @get('assessment.authable').then (authable) =>
        @totem_scope.set_authable(authable)
        review.save().then =>
          @totem_messages.api_success source: @, model: review, action: 'update', i18n_path: ns.to_o('tbl:review', 'save')
        , (error) => @totem_messages.api_failure error, source: @, model: review, action: 'update'

    approve:   -> @state_change('approve')
    unapprove: -> @state_change('unapprove')
    ignore:    -> @state_change('ignore')
