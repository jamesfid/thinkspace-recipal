import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/admin/irat/to_trat'

export default base.extend

  init: ->
    @_super()
    @irad.set 'transition_now', true

  validate_data: ->
    @irad.clear_errors()
    @trad.clear_errors()
    @trad.error 'You have not selected any teams.' if ember.isBlank @trad.get_teams()
