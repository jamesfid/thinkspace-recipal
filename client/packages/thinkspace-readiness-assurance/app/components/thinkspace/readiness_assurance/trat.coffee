import ember from 'ember'
import base  from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend

  willInsertElement: ->
    @ra.tracker()
    @ra.load_messages()

