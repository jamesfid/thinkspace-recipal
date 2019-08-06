import ember            from 'ember'
import ns               from 'totem/ns'
import response_manager from 'thinkspace-readiness-assurance/response_manager'
import base             from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  willInsertElement: ->
    readonly   = @get('viewonly')
    assessment = @get('model')
    rm         = response_manager.create(container: @container)
    rm.init_manager
      assessment: assessment
      readonly:   readonly
      irat:       true
    @set 'rm', rm
