import ember from 'ember'
import base  from 'ember-validations/validators/base'

export default base.extend

  call: ->
    password = @get(@property)
    return unless password
    score = window.zxcvbn(password).score
    min   = @options.minimum or 3
    msg   = @options.message or 'Must use a "Good" or "Strong" password.  Try using a combination of numbers, letters, and symbols.'
    if score < min
      @errors.pushObject(msg)
