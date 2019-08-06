import ember from 'ember'
import ta    from 'totem/ds/associations'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import util from 'totem/util'
import base from './form'

export default base.extend
  # Properties
  color: ember.computed.reads 'model.color'
  title: ember.computed.reads 'model.title'

  css_style: ember.computed 'color', ->
    color = @get 'color'
    return '' unless ember.isPresent(color)
    css = ''
    css += "background-color: ##{color};"
    new ember.Handlebars.SafeString css

  get_model: -> 
    new ember.RSVP.Promise (resolve, reject) => resolve @get('model')

  reset: ->
    @set 'color', @get('model.color')
    @set 'title', @get('model.title')

  transition_from_save: (team) -> @get('team_manager').transition_to_team_set_show(team)

  actions:
    destroy: ->
      team = @get 'model'
      team.get(ns.to_p('team_set')).then (team_set) =>
        @totem_messages.show_loading_outlet(message: 'Deleting team...')
        team.destroyRecord().then (team) =>
          team_set.decrement_team_count()
          @get('team_manager').update_unassigned_users()
          @get('team_manager').transition_to_team_set_show(team)
          @totem_messages.hide_loading_outlet()