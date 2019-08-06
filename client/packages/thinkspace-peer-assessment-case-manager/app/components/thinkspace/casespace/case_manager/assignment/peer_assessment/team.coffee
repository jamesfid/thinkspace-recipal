import ember          from 'ember'
import ns             from 'totem/ns'
import ajax           from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # ### Properties
  tagName:      ''
  is_expanded:  false
  assessment:   null
  team_sets:    null
  review_sets:  null

  # ### Computed properties
  team_members: ember.computed.reads 'model.users'

  team_set:     ember.computed 'team_sets', 'model', ->
    team_sets = @get 'team_sets'
    team_id   = parseInt @get 'model.id'
    return unless ember.isPresent(team_sets) and ember.isPresent(team_id)
    team_sets.findBy('team_id', team_id)

  is_approvable: ember.computed 'team_set.state', 'team_set', ->
    team_set = @get 'team_set'
    return false unless ember.isPresent(team_set)
    team_set.get 'is_approvable'

  css_style_team_header: ember.computed 'model.color', ->
    color = @get 'model.color'
    return '' unless ember.isPresent(color)
    css   = ''
    css  += "background-color: ##{color};"
    css  += "border-color: ##{color};"
    new ember.Handlebars.SafeString css

  css_style_team_content: ember.computed 'model.color', ->
    color = @get 'model.color'
    return '' unless ember.isPresent(color)
    css   = ''
    css  += "border-color: ##{color};"
    new ember.Handlebars.SafeString css

  dropdown_collection: ember.computed 'model', ->
    collection = []
    collection.pushObject {display: 'Approve <strong>team only</strong>', action: 'approve'}
    collection.pushObject {display: 'Re-open <strong>team only</strong>', action: 'unapprove'}
    collection

  # ### Components
  c_user:                  ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'user'
  c_state:                 ns.to_p 'case_manager', 'assignment', 'peer_assessment', 'state'
  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'

  # ### Helpers
  toggle_is_expanded: ->
    if @get 'is_expanded'
      @toggleProperty 'is_expanded'
    else
      @get_review_sets().then (review_sets) =>
        @toggleProperty 'is_expanded'

  get_review_sets: ->
    query =
      model:  ns.to_p 'tbl:assessment'
      verb:   'get'
      action: 'review_sets'
      id:     @get 'assessment.id'
      data:   
        team_id: @get 'model.id'

    ajax.object(query).then (payload) =>
      review_sets = ajax.normalize_and_push_payload 'tbl:review_set', payload
      console.log "[tbl-pa-cm] Review set returned as: ", review_sets
      @set 'review_sets', review_sets

  state_change: (state) ->
    team_set = @get 'team_set'
    query    = 
      id:     team_set.get 'id'
      action: state
      verb:   'PUT'
    @tc.query(ns.to_p('tbl:team_set'), query, single: true)

  actions:
    toggle:        -> @toggle_is_expanded()
    approve:       -> @state_change('approve')
    unapprove:     -> @state_change('unapprove')
    approve_all:   -> @state_change('approve_all')
    unapprove_all: -> @state_change('unapprove_all')
