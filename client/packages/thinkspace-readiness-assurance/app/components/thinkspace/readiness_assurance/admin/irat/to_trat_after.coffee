import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/irat/to_trat'

export default base.extend

  # TODO: Reset due_at on send_transition incase delayed pressing transition button?

  init: ->
    @_super()
    @trad.select_all_teams_on()

  button_range: [
    {start: 1,  end: 5,  by: 1}
    {start: 10, end: 30, by: 5}
  ]
