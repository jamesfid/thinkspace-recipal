import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/component'

export default base.extend

  init: ->
    @_super()
    @irad = @am.rad(name: 'IRAT', width_selector: '.ts-ra_admin-phase-states-content')

  willInsertElement: ->
    @am.get_trat_team_users().then (team_users) =>
      @irad.set_team_users(team_users)
      # @irad.select_all_users_on()
      @irad.show_all_on()
      @set_ready_on()

  actions:
    validate: -> @validate()

    send_phase_states: ->
      @validate()
      @selected_send_on()
      return if ember.isPresent(@irad.errors)
      irat = @irad.get_data()
      @am.send_irat_phase_states({irat})

  validate: ->
    @irad.clear_errors()
    @irad.error 'No users are selected.'  if ember.isBlank(@irad.get_users())
    @irad.error 'No state selected.'      if ember.isBlank(@irad.get_phase_state())
