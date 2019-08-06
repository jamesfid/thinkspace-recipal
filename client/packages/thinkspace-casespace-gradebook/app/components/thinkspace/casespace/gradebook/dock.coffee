import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-casespace/components/dock_base'

export default base.extend

  totem_data_config: ability: {model: 'current_assignment'}

  casespace_gradebook: ember.inject.service()

  addon_name:         'gradebook'
  addon_display_name: 'Gradebook'

  c_assignment:   ns.to_p 'gradebook', 'assignment'
  c_phase:        ns.to_p 'gradebook', 'phase'

  can_grade_assignment: ember.computed.bool 'can.gradebook'
  can_grade_phase:      ember.computed.and  'can_grade_assignment', 'has_phase_view'

  assignment_change: ember.computed 'current_assignment', -> @totem_data.ability.refresh()  if ember.isPresent @get('current_assignment')
  
  can_access_addon: ember.computed 'current_phase', 'can_grade_assignment', 'can_grade_phase', ->
    if @get('current_phase')
      @get('can_grade_phase') 
    else
      @get('can_grade_assignment')

  exit_addon: -> @get('casespace_gradebook').clear()

  valid_addon_ownerable: (addon_ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_ownerable(addon_ownerable).then (valid) ->
        resolve(valid)

  validate_ownerable: (ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      pm_map              = @get('phase_manager.map')
      map                 = @get('casespace_gradebook')
      space               = @get('current_space')
      assignment          = @get('current_assignment')
      phase               = @get('current_phase')
      return resolve(false)  unless phase
      if phase.is_team_ownerable()
        map.get_gradebook_phase_teams(assignment, phase).then (teams) =>
          resolve teams.contains(ownerable)
      else
        map.get_gradebook_users(space, assignment).then (users) =>
          resolve users.contains(ownerable)