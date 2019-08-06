import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-readiness-assurance/base/admin/component'

export default base.extend

  show_teams: ember.observer 'show_all', -> @set 'show_team', @get('show_all')
  selected:   ember.computed 'selected_users.[]', -> @selected_users.contains(@user)

  show_team: false

  actions:
    select: -> @sendAction 'select', @user

    toggle_team: -> @toggleProperty('show_team'); return
