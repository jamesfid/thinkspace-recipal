import ember from 'ember'
import ta from 'totem/ds/associations'
import avatar from 'thinkspace-common/mixins/avatar'

export default ta.Model.extend avatar, ta.add(
  ta.has_many 'disciplines', reads: {}
  ta.has_many 'keys', reads: {}
  ),


  email:             ta.attr('string')
  first_name:        ta.attr('string')
  last_name:         ta.attr('string')
  state:             ta.attr('string')
  activated_at:      ta.attr('date')
  profile:           ta.attr()
  terms_accepted_at: ta.attr('date')
  email_optin:       ta.attr('boolean')
  updates:           ta.attr()
  tos_current:       ta.attr('boolean')
  has_key:           ta.attr('boolean')

  full_name:     ember.computed 'first_name', 'last_name', ->
    first_name   = @get('first_name') or '?'
    last_name    = @get('last_name')  or '?'
    email        = @get('email')
    if last_name == '?' then "#{first_name} #{last_name} - #{email}" else "#{first_name} #{last_name}" 
  sort_name:     ember.computed -> "#{@get('last_name')}, #{@get('first_name')}"
  html_title:    ember.computed -> "#{@get('full_name')} - #{@get('email')}"
  first_initial: ember.computed 'first_name', -> @get_initial_from_name(@get('first_name'))
  last_initial:  ember.computed 'last_name', -> @get_initial_from_name(@get('last_name'))
  display_name:  ember.computed.reads 'full_name'
  initials:      ember.computed 'first_name', 'last_name', -> "#{@get('first_initial')} #{@get('last_initial')}"
  color_string:  ember.computed 'initials', -> "#{@get('initials')}-#{@get('id')}"
  color:         'eeeeee'

  invitation_status: ember.computed 'state', ->
    return 'Accepted' if @get('is_active')
    return 'Pending' if @get('is_inactive')

  is_active:   ember.computed.equal 'state', 'active'
  is_inactive: ember.computed.equal 'state', 'inactive'

  get_initial_from_name: (name) ->
    return '?' unless ember.isPresent(name)
    name.charAt(0).capitalize()

  # ### Profile
  is_student: ember.computed.equal 'profile.roles.student', true
  is_teacher: ember.computed.equal 'profile.roles.instructor', true
