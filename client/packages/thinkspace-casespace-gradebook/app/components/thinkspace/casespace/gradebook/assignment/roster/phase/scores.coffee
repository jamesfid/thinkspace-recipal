import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import calc  from 'thinkspace-casespace-gradebook/calc'
import gch   from 'thinkspace-casespace-gradebook/common_helpers'
import group_by_mixin from 'totem/mixins/group_by'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend group_by_mixin,

  show_non_zero_supplement: true
  c_dropdown_split_button:  ns.to_p 'common', 'dropdown_split_button'
  c_score:                  ns.to_p 'gradebook', 'assignment', 'roster', 'shared', 'score'
  c_state:                  ns.to_p 'gradebook', 'assignment', 'roster', 'shared', 'state'
  t_sort_links:             ns.to_t 'gradebook', 'assignment', 'roster', 'shared', 'sort_links'
  t_table_options:          ns.to_t 'gradebook', 'assignment', 'roster', 'shared', 'table_options'
  t_group_1:                ns.to_t 'gradebook', 'assignment', 'roster', 'phase', 'group_1'
  t_group_1_sort_by:        ns.to_t 'gradebook', 'assignment', 'roster', 'phase', 'group_1_sort_by'
  t_group_2:                ns.to_t 'gradebook', 'assignment', 'roster', 'phase', 'group_2'
  t_group_2_sort_by:        ns.to_t 'gradebook', 'assignment', 'roster', 'phase', 'group_2_sort_by'
  t_supplement:             ns.to_t 'gradebook', 'assignment', 'roster', 'phase', 'supplement'

  is_group_1: ember.computed.equal 'roster.content.groups', 1
  is_group_2: ember.computed.equal 'roster.content.groups', 2
  decimals:   ember.computed.reads 'roster.content.decimals'
  supplement: ember.computed.reads 'roster.content.supplement'

  server_roster:     null
  show_scores:       true
  sort_order:        null
  row_number:        null
  edit_visible:      false
  selected_decimals: 2

  sort_links: ember.computed 'sort_order', -> gch.get_sort_links @get_sort_def(), @get_sort_order(), @get_sort_link_for()

  dropdown_collection: ember.computed 'sort_order', ->
    collection = []
    sort_links = gch.get_sort_links @get_sort_def(), @get_sort_order(), @get_sort_link_for()
    sort_links.forEach (sort_link) => collection.pushObject {display: sort_link.text, action: sort_link.key}
    collection

  selected_sort_order: ember.computed 'sort_order', ->
    sort_links = gch.get_sort_links @get_sort_def(), @get_sort_order(), @get_sort_link_for()
    selected   = sort_links.findBy 'active', true
    selected
    
  roster: ember.computed 'sort_order', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @set 'show_scores', false  # remove the 'each' loop in the view until the roster is set e.g. via run.next
      ember.run.next =>
        @get_roster().then (roster) =>
          @totem_messages.hide_loading_outlet()
          @set 'row_number', 0
          resolve(roster)
          @set 'show_scores', true
    ds.PromiseObject.create promise: promise

  sort_def: # Add :asc (default) or :desc to sort options if needed e.g. 'user:desc'.
    # by_user:            {for: 'user', sort: ['user'],                    heading: {column_1: 'Student'},                                                title: 'By Student'}
    # by_score_user:      {for: 'user', sort: ['score', 'user'],           heading: {column_1: 'Student'},                      heading_sort_by: 'Score', title: 'By Score to Student'}
    # by_state_user:      {for: 'user', sort: ['state', 'user'],           heading: {column_1: 'Student'},                      heading_sort_by: 'State', title: 'By State to Student'}
    # by_user_team:       {for: 'team', sort: ['user', 'team'],            heading: {column_1: 'Student', column_2: 'Team'},                              title: 'By Team'}
    # by_team_user:       {for: 'team', sort: ['team', 'user'],            heading: {column_1: 'Team',    column_2: 'Student'},                           title: 'By Team to Student'}
    # by_score_team_user: {for: 'team', sort: ['score', 'team', 'user'],   heading: {column_1: 'Team',    column_2: 'Student'}, heading_sort_by: 'Score', title: 'By Score to Team to Student'}
    # by_state_team_user: {for: 'team', sort: ['state', 'team', 'user'],   heading: {column_1: 'Team',    column_2: 'Student'}, heading_sort_by: 'State', title: 'By State to Team to Student'}
    # by_score_user_team: {for: 'team', sort: ['score', 'user', 'team'],   heading: {column_1: 'Student', column_2: 'Team'},    heading_sort_by: 'Score', title: 'By Score to Student to Team'}
    # by_state_user_team: {for: 'team', sort: ['state', 'user', 'team'],   heading: {column_1: 'Student', column_2: 'Team'},    heading_sort_by: 'State', title: 'By State to Student to Team'}

    # Student
    by_user:            {for: 'user', sort: ['user'],                    heading: {column_1: 'Student'},                                                title: 'Last Name ( A - Z )'}
    # Score to Student
    by_score_user:      {for: 'user', sort: ['score', 'user'],           heading: {column_1: 'Student'},                      heading_sort_by: 'Score', title: 'Score (high - low)'}
    # By State to Student
    by_state_user:      {for: 'user', sort: ['state', 'user'],           heading: {column_1: 'Student'},                      heading_sort_by: 'State', title: 'Phase State '}
    # By Team
    by_user_team:       {for: 'team', sort: ['user', 'team'],            heading: {column_1: 'Student', column_2: 'Team'},                              title: 'Teams'}
    # By Team to Student
    by_team_user:       {for: 'team', sort: ['team', 'user'],            heading: {column_1: 'Team',    column_2: 'Student'},                           title: 'By Team to Student'}
    # By Score to Team to Student
    by_score_team_user: {for: 'team', sort: ['score', 'team', 'user'],   heading: {column_1: 'Team',    column_2: 'Student'}, heading_sort_by: 'Score', title: 'By Score to Team to Student'}
    # By State to Team to Student
    by_state_team_user: {for: 'team', sort: ['state', 'team', 'user'],   heading: {column_1: 'Team',    column_2: 'Student'}, heading_sort_by: 'State', title: 'By State to Team to Student'}
    # By Score to Student to Team
    by_score_user_team: {for: 'team', sort: ['score', 'user', 'team'],   heading: {column_1: 'Student', column_2: 'Team'},    heading_sort_by: 'Score', title: 'By Score to Student to Team'}
    # By State to Student  to Team
    by_state_user_team: {for: 'team', sort: ['state', 'user', 'team'],   heading: {column_1: 'Student', column_2: 'Team'},    heading_sort_by: 'State', title: 'By State to Student to Team'}

  get_sort_def:        -> @get('sort_def')
  get_sort_order:      -> @get('sort_order') or (@get('model.team_ownerable') and 'by_user_team') or 'by_user'
  get_sort_link_for:   -> (@get('model.team_ownerable') and 'team') or 'user'
  get_number_decimals: -> @get('selected_decimals')
  rerender_view:       -> @notifyPropertyChange 'sort_order'

  set_decimals_from_offset: (offset) ->
    decimals = @get 'selected_decimals' or 2
    @set 'selected_decimals', decimals + offset
    @rerender_view()

  actions:
    by_user:            -> @set 'sort_order', 'by_user'
    by_score_user:      -> @set 'sort_order', 'by_score_user'
    by_state_user:      -> @set 'sort_order', 'by_state_user'
    by_team_user:       -> @set 'sort_order', 'by_team_user'
    by_user_team:       -> @set 'sort_order', 'by_user_team'
    by_score_team_user: -> @set 'sort_order', 'by_score_team_user'
    by_state_team_user: -> @set 'sort_order', 'by_state_team_user'
    by_score_user_team: -> @set 'sort_order', 'by_score_user_team'
    by_state_user_team: -> @set 'sort_order', 'by_state_user_team'

    toggle_edit: ->
      @toggleProperty 'edit_visible'
      @rerender_view()

    increase_decimals: -> @set_decimals_from_offset(1)
    decrease_decimals: -> @set_decimals_from_offset(-1)

    save_score: (values, score) -> gch.update_roster_score(@get_server_roster_scores(), values, score).then => @rerender_view()
    save_state: (values, state) -> gch.update_roster_state(@get_server_roster_scores(), values, state).then => @rerender_view()

    view_phase_list: -> @sendAction 'view_phase_list'

  # ###
  # ### Roster.
  # ###

  get_roster: ->
    new ember.RSVP.Promise (resolve, reject) =>
      if @get_server_roster()
        @get_roster_values().then (roster) => resolve(roster)
      else
        gch.get_phase_roster_from_server(@get('assignment'), @get('model')).then (roster) =>
          roster.scores = roster.scores.map (hash) ->
            hash.score = Number(hash.score)
            ember.Object.create(hash)
          @set_server_roster(roster)
          @get_roster_values().then (roster_values) => resolve(roster_values)

  get_roster_values: ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase      = @get('model')
      sort_order = @get_sort_order()
      sort_def   = @get("sort_def.#{sort_order}")
      roster     = {}
      # set roster values
      roster.supplement      = @get_roster_supplement(sort_def)
      roster.decimals        = @get_number_decimals()
      roster.heading         = sort_def.heading
      roster.heading_sort_by = sort_def.heading_sort_by
      sort                   = sort_def.sort or []
      roster.groups          = sort.get('length')
      roster.groups         -= 1  if roster.heading_sort_by?
      options                = ember.merge({}, sort_def)
      options.add_props      = ['score', 'state', 'state_id', 'multiple_scores', 'team_ownerable', 'phase_id']
      options.find           = {score: 'score', state: 'state'}
      roster.group_values    = @group_values(@get_server_roster_scores(), options)
      resolve(roster)

  get_server_roster:          -> @get 'server_roster'
  set_server_roster: (roster) -> @set 'server_roster', roster
  get_server_roster_scores:   -> @get 'server_roster.scores'

  get_roster_supplement: (sort_def) ->
    sup          = {}
    sup.decimals = @get_number_decimals()
    scores       = @get_server_roster_scores()
    scores_array = scores.mapBy 'score'
    # supplement base
    sup.base            = calc.values(scores_array)
    user_count          = calc.count_uniq_key_values(scores, 'user_id')
    sup.base.user_count = user_count  unless user_count == sup.base.count
    # supplement non_zero
    sup.non_zero            = calc.non_zero_values(scores_array)
    user_count              = calc.count_non_zero_uniq_key_values(scores, 'score', 'user_id')
    sup.non_zero.user_count = user_count  unless user_count == sup.non_zero.count
    sup
