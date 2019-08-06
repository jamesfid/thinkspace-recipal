import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  tagName:       'li'
  is_expanded:   false
  selected_user: null

  has_users: ember.computed.gte 'model.users.length', 1

  css_style: ember.computed 'model.color', ->
    color = @get 'model.color'
    return '' unless ember.isPresent(color)
    css = ''
    css += "background-color: ##{color};"
    new ember.Handlebars.SafeString css

  # Components
  c_user_avatar:   ns.to_p 'common', 'user', 'avatar'

  # Routes
  r_teams_edit:   ns.to_r 'case_manager', 'teams', 'edit'

  click: ->
    user   = @get 'selected_user'
    return unless ember.isPresent(user)
    team   = @get 'model'
    return if team.get 'is_locked'
    team.add_user(user)
    @sendAction 'deselect_user'
    

  actions:
    toggle_expanded: ->
      @toggleProperty 'is_expanded'