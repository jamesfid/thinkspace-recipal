import ember from 'ember'
import base from 'ember-validations/validators/base'

export default base.extend

  init: ->
    @_super()
    @dependentValidationKeys.pushObject("submit_visible")

  call: ->
    text    = @get('submit_text')
    visible = @get('submit_visible')
    if visible and !text
      @errors.pushObject "submit text is required if the button is visible"
