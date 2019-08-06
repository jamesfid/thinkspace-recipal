import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import calc  from 'thinkspace-casespace-gradebook/calc'
import gch   from 'thinkspace-casespace-gradebook/common_helpers'
import group_by_mixin from 'totem/mixins/group_by'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend group_by_mixin,

  c_dropdown_split_button: ns.to_p 'common', 'dropdown_split_button'
  c_score:                 ns.to_p 'gradebook', 'assignment', 'roster', 'shared', 'score'
  t_sort_links:            ns.to_t 'gradebook', 'assignment', 'roster', 'shared', 'sort_links'
  t_table_options:         ns.to_t 'gradebook', 'assignment', 'roster', 'shared', 'table_options'
  t_header:                ns.to_t 'gradebook', 'assignment', 'roster', 'assignment', 'header'
  t_group:                 ns.to_t 'gradebook', 'assignment', 'roster', 'assignment', 'group'
  t_group_sort_by:         ns.to_t 'gradebook', 'assignment', 'roster', 'assignment', 'group_sort_by'
  t_supplement:            ns.to_t 'gradebook', 'assignment', 'roster', 'assignment', 'supplement'

  decimals:   ember.computed.reads 'roster.content.decimals'
  supplement: ember.computed.reads 'roster.content.supplement'
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

  server_roster:     null
  show_scores:       true
  sort_order:        null
  row_number:        null
  edit_visible:      false
  selected_decimals: 2

  sort_def:  # Add :asc (default) or :desc to sort options if needed e.g. 'user:desc'.
    by_user:       {sort: ['user', 'phase', 'team'],          heading: {column_1: 'Student'},                           title: 'Last Name ( A - Z )'}
    by_score_user: {sort: ['total', 'user', 'phase', 'team'], heading: {column_1: 'Student'}, heading_sort_by: 'Total', title: 'Total Score'}

  get_sort_def:        -> @get('sort_def')
  get_sort_order:      -> @get('sort_order') or 'by_user'
  get_sort_link_for:   -> 'all'
  get_number_decimals: -> @get('selected_decimals')
  rerender_view:       -> @notifyPropertyChange 'sort_order'

  set_decimals_from_offset: (offset) ->
    decimals = @get 'selected_decimals' or 2
    @set 'selected_decimals', decimals + offset
    @rerender_view()

  actions:
    by_user:       -> @set 'sort_order', 'by_user'
    by_score_user: -> @set 'sort_order', 'by_score_user'

    toggle_edit: ->
      @toggleProperty 'edit_visible'
      @rerender_view()

    increase_decimals: -> @set_decimals_from_offset(1)
    decrease_decimals: -> @set_decimals_from_offset(-1)

    save_score: (values, score) -> gch.update_roster_score(@get_server_roster_scores(), values, score).then => @rerender_view()
    save_state: (values, state) -> gch.update_roster_state(@get_server_roster_scores(), values, state).then => @rerender_view()

    select_sort_link: (sort_link) -> 
      @send sort_link.action if sort_link.action
      true


  # ###
  # ### Roster.
  # ###

  get_roster: ->
    new ember.RSVP.Promise (resolve, reject) =>
      if @get_server_roster()
        @get_roster_values().then (roster) => resolve(roster)
      else
        # Flatten and convert the roster scores to ember objects.
        gch.get_assignment_roster_from_server(@get 'model').then (roster) =>
          scores = []
          roster.scores.forEach (phase_scores) =>
            phase_scores.forEach (hash) =>
              hash.score = Number(hash.score)
              hash.total = Number(hash.total)
              if hash.team_ownerable
                hash.multiple_scores = (hash.team_count > 1)
              else
                hash.team_ownerable  = false
                hash.team_id         = 0
                hash.team_label      = ' '
                hash.multiple_scores = false
              scores.push ember.Object.create(hash)
          roster.original_scores = roster.scores
          roster.scores = scores
          @set_server_roster(roster)
          @get_roster_values().then (roster_values) => resolve(roster_values)

  get_roster_values: ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment    = @get('model')
      sort_order    = @get_sort_order()
      sort_def      = @get("sort_def.#{sort_order}")
      server_roster = @get_server_roster()
      roster        = {}
      # set roster values
      roster.phases          = @get_server_roster_phases()
      roster.supplement      = @get_roster_supplement(sort_def)
      roster.decimals        = @get_number_decimals()
      roster.heading         = sort_def.heading
      roster.heading_sort_by = sort_def.heading_sort_by
      @set_user_totals()
      options             = ember.merge({}, sort_def)
      options.add_props   = ['score', 'total', 'phase_position', 'state_id', 'multiple_scores', 'team_ownerable']
      options.find        = {total: 'total'}
      options.sort_by     = {phase: 'phase_position'}
      roster.group_values = @group_values(@get_server_roster_scores(), options)
      resolve(roster)

  set_user_totals: ->
    scores   = @get_server_roster_scores()
    user_ids = scores.mapBy('user_id').uniq()
    user_ids.forEach (id) =>
      total  = calc.total(scores.filterBy('user_id', id).mapBy('score'))
      hashes = scores.filterBy 'user_id', id
      hashes.forEach (hash) => hash.total = total

  get_server_roster:          -> @get 'server_roster'
  set_server_roster: (roster) -> @set 'server_roster', roster
  get_server_roster_scores:   -> @get 'server_roster.scores'
  get_server_roster_phases:   -> (@get('server_roster.phases') or []).sortBy 'position'

  get_roster_supplement: (sort_def) ->
    sup          = {}
    sup.base     = []
    sup.decimals = @get_number_decimals()
    phases       = @get_server_roster_phases()
    scores       = @get_server_roster_scores()

    phases.forEach (phase) =>
      phase_id            = phase.id
      phase_hashes        = scores.filterBy 'phase_id', phase_id
      phase_scores        = phase_hashes.mapBy 'score'
      phase_sup           = calc.values(phase_scores)
      phase_sup.title     = phase.title
      user_count          = calc.count_uniq_key_values(phase_hashes, 'user_id')
      unless user_count == phase_sup.count
        sup.has_user_count   = true
        phase_sup.user_count = user_count
      sup.base.push phase_sup
    total_scores       = calc.values(scores.mapBy 'score')
    total_scores.title = 'Totals'
    total_scores.count = ''
    sup.base.push total_scores
    sup
    