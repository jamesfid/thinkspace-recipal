import ember from 'ember'
import ta    from 'totem/ds/associations'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import util from 'totem/util'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  title: ember.computed -> console.error "Implement a specific title property for new/edit team form components."
  color: ember.computed -> console.error "Implement a specific color property for new/edit team form components."
  css_style: ember.computed 'color', ->
    color = @get 'color'
    return '' unless ember.isPresent(color)
    css = ''
    css += "background-color: ##{color};"
    new ember.Handlebars.SafeString css

  users_to_add:    null # Defaulted in init, reference: http://stackoverflow.com/questions/24210093/reset-ember-component-on-load
  users_to_remove: null

  space:                   ember.computed.reads 'team_manager.current_space'
  current_users:           ember.computed.reads 'team_manager.current_users'
  team_users:              ember.computed -> @get('team_manager').team_users_for_team @get('model')
  unassigned_users:        ember.computed.reads 'team_manager.current_unassigned_users'
  unassigned_users_loaded: ember.computed.reads 'team_manager.current_unassigned_users_loaded'

  # Components
  c_space_header:           ns.to_p 'space', 'header'
  c_team_member_unassigned: ns.to_p 'case_manager', 'team', 'member', 'unassigned'

  # Routes
  r_team_sets_show: ns.to_r 'case_manager', 'team_sets', 'show'

  # Services
  team_manager: ember.inject.service()

  init: ->
    @_super()
    @set 'users_to_add', []
    @set 'users_to_remove', []

  get_store: -> @container.lookup('store:main')

  reset_user_arrays: ->
    @get('users_to_add').clear()
    @get('users_to_remove').clear()
  reset_team: -> @get('model').reset_all()
  reset_all:  -> 
    @reset_user_arrays()
    @reset_team()
    @get('team_manager').update_unassigned_users()
  get_model:            -> console.error "Implement a specific get_model for new/edit team form components."
  transition_from_save: (team) -> console.error "Implement a specific transition_from_save for new/edit team form components."

  actions:
    add_user_to_team: (user) ->
      users_to_add = @get 'users_to_add'
      if users_to_add.contains(user) then users_to_add.removeObject(user) else users_to_add.pushObject(user)

    remove_user_from_team: (user) ->
      users_to_remove = @get 'users_to_remove'
      if users_to_remove.contains(user) then users_to_remove.removeObject(user) else users_to_remove.pushObject(user)

    save: ->
      @get_model().then (team) =>
        users_to_add    = @get 'users_to_add'
        users_to_remove = @get 'users_to_remove'
        remove_ids      = null

        team.add_users(users_to_add) if ember.isPresent(users_to_add)
        if ember.isPresent(users_to_remove)
          remove_ids      = util.string_array_to_numbers users_to_remove.mapBy('id')
          team.remove_users(users_to_remove) 
        team.set 'title', @get('title')
        team.set 'color', @get('color')

        team.save().then (team) =>
          if @get('is_new')
            team.get('team_set').then (team_set) => team_set.increment_team_count()
          if ember.isPresent(remove_ids)
            team.unload_team_users(remove_ids).then =>
              @reset_all()
              @transition_from_save(team)
          else
            @reset_all()
            @transition_from_save(team)
        , (error) => team.rollback(); @reset()
