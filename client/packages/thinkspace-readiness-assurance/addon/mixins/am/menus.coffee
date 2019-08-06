import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  # Menu Component Paths.
  c_menu_dashbaord:    ns.to_p 'ra:admin', 'menu', 'dashboard'
  c_menu_irat:         ns.to_p 'ra:admin', 'menu', 'irat'
  c_menu_irat_to_trat: ns.to_p 'ra:admin', 'menu', 'irat_to_trat'
  c_menu_messages:     ns.to_p 'ra:admin', 'menu', 'messages'
  c_menu_timers:       ns.to_p 'ra:admin', 'menu', 'timers'
  c_menu_trat:         ns.to_p 'ra:admin', 'menu', 'trat'
  c_menu_trat_summary: ns.to_p 'ra:admin', 'menu', 'trat_summary'

  #
  # Main Component Paths (e.g. can also be in a menu config).
  # Main components must 'not' depend on values passed on the 'component' helper
  # other than the 'config' and action 'done'.
  #
  c_messages_send:       ns.to_p 'ra:admin', 'messages', 'send'
  c_messages_view:       ns.to_p 'ra:admin', 'messages', 'view'

  c_timers_active:       ns.to_p 'ra:admin', 'timers', 'active'
  c_tracker_show:        ns.to_p 'ra:admin', 'tracker', 'show'

  c_irat_phase_states:   ns.to_p 'ra:admin', 'irat', 'phase_states'
  c_irat_to_trat_after:  ns.to_p 'ra:admin', 'irat', 'to_trat_after'
  c_irat_to_trat_due_at: ns.to_p 'ra:admin', 'irat', 'to_trat_due_at'
  c_irat_to_trat_now:    ns.to_p 'ra:admin', 'irat', 'to_trat_now'

  c_trat_phase_states:    ns.to_p 'ra:admin', 'trat', 'phase_states'
  c_trat_summary_answers: ns.to_p 'ra:admin', 'trat', 'summary', 'answers'
  c_trat_summary_teams:   ns.to_p 'ra:admin', 'trat', 'summary', 'teams'
  c_trat_teams:           ns.to_p 'ra:admin', 'trat', 'teams', 'show'

  # Component Helper Paths.
  c_trat_summary_answers_answer: ns.to_p 'ra:admin', 'trat', 'summary', 'answers', 'answer'
  c_trat_summary_teams_team:     ns.to_p 'ra:admin', 'trat', 'summary', 'teams', 'team'
  c_trat_summary_teams_team_qm:  ns.to_p 'ra:admin', 'trat', 'summary', 'teams', 'team_qm'
  c_trat_teams_users:            ns.to_p 'ra:admin', 'trat', 'teams', 'users', 'show'

  # Shared Component Paths.
  c_admin_shared_error:         ns.to_p 'ra:admin', 'shared', 'error'
  c_admin_shared_menu:          ns.to_p 'ra:admin', 'shared', 'menu'
  c_admin_shared_message:       ns.to_p 'ra:admin', 'shared', 'message'
  c_admin_shared_phase_states:  ns.to_p 'ra:admin', 'shared', 'phase_states'
  c_admin_shared_time_at:       ns.to_p 'ra:admin', 'shared', 'time_at'
  c_admin_shared_time_after:    ns.to_p 'ra:admin', 'shared', 'time_after'
  c_admin_shared_toggle_select: ns.to_p 'ra:admin', 'shared', 'toggle_select'

  # Shared Sub-Component Paths.
  c_admin_shared_radio_buttons:     ns.to_p 'ra:admin', 'shared', 'radio', 'buttons'
  c_admin_shared_radio_button:      ns.to_p 'ra:admin', 'shared', 'radio', 'button'
  c_admin_shared_team_users_select: ns.to_p 'ra:admin', 'shared', 'team_users', 'select'
  c_admin_shared_team_users_team:   ns.to_p 'ra:admin', 'shared', 'team_users', 'team'
  c_admin_shared_team_users_user:   ns.to_p 'ra:admin', 'shared', 'team_users', 'user'
  c_admin_shared_teams_select:      ns.to_p 'ra:admin', 'shared', 'teams', 'select'
  c_admin_shared_teams_team:        ns.to_p 'ra:admin', 'shared', 'teams', 'team'
  c_admin_shared_timer_show:        ns.to_p 'ra:admin', 'shared', 'timer', 'show'
  c_admin_shared_timer_interval:    ns.to_p 'ra:admin', 'shared', 'timer', 'interval'
  c_admin_shared_timer_reminders:   ns.to_p 'ra:admin', 'shared', 'timer', 'reminders'
  c_admin_shared_users_select:      ns.to_p 'ra:admin', 'shared', 'users', 'select'
  c_admin_shared_users_user:        ns.to_p 'ra:admin', 'shared', 'users', 'user'

  # Non-Admin Shared Component Paths.
  c_shared_messages_view: ns.to_p 'readiness_assurance', 'shared', 'messages', 'view'
  c_date_picker:          ns.to_p 'common', 'date_picker'
  c_time_picker:          ns.to_p 'common', 'time_picker'

  # ###
  # ### Menu Configs.
  # ###

  dashboard_menu: ember.computed ->
    [
      {component: @c_menu_irat,     title: 'IRAT', clear: true}
      {component: @c_menu_trat,     title: 'TRAT', clear: true}
      {component: @c_menu_messages, title: 'Messages', clear: true}
      {component: @c_menu_timers,   title: 'Timers', clear: true}
      {component: @c_timers_active, title: 'Active Timers', clear: true}
      {component: @c_tracker_show,  title: 'Tracker', clear: false, clearable: false}
    ]

  messages_menu: ember.computed ->
    [
      {component: @c_messages_send, title: 'Send Message', default: true}
      {component: @c_messages_view, title: 'View Message', top: true}
    ]

  timers_menu: ember.computed ->
    [
      {component: @c_timers_active,  title: 'Active'}
    ]

  irat_menu: ember.computed ->
    [
      {component: @c_menu_irat_to_trat, title: 'Transition Teams to TRAT', clear: true}
      {component: @c_irat_phase_states, title: 'Phase States', clear: true}
      {component: @c_messages_view,     title: 'View Messages', top: true, first: true, clearable: false}
      {component: @c_timers_active,     title: 'Active Timers', top: true}
    ]

  irat_to_trat_menu: ember.computed ->
    [
      {component: @c_irat_to_trat_after,  title: 'After',  clear: true, default: true}
      {component: @c_irat_to_trat_due_at, title: 'Due At', clear: true}
      {component: @c_irat_to_trat_now,    title: 'Now',    clear: true}
    ]

  trat_menu: ember.computed ->
    [
      {component: @c_trat_teams,         title: 'Teams'}
      {component: @c_menu_trat_summary,  title: 'Summary'}
      {component: @c_trat_phase_states,  title: 'Phase States', clear: true}
      {component: @c_messages_view,      title: 'View Messages', top: true, clearable: false}
    ]

  trat_summary_menu: ember.computed ->
    [
      {component: @c_trat_summary_answers,  title: 'By Answer Counts', default: true}
      {component: @c_trat_summary_teams,    title: 'By Teams'}
    ]

  # Return the 'select' menu component property for (team_users | teams | users) defined in config.select (default team_users).
  select_component: (config) ->
    val  = config.select or 'team_users'
    @["c_admin_shared_#{val}_select"]
