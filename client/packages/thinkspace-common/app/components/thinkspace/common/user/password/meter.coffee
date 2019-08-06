import ember          from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: ''

  password: null

  password_score:      0
  password_score_text: null
  password_strength:
    0: 'Worst'
    1: 'Bad'
    2: 'Weak'
    3: 'Good'
    4: 'Strong'

  password_strength_error_message: 'Must use a good or strong password.'

  password_observer: ember.observer 'password', ->
    @set_password_meter()

  didInsertElement: ->
    @set_password_meter()

  set_password_meter: ->
    password = @get('password')
    if ember.isBlank(password)
      @set 'password_score', 0
      @set 'password_score_text', null
      return
    score = window.zxcvbn(password).score
    @set 'password_score', score
    @set 'password_score_text', @get('password_strength')[score] || ''
