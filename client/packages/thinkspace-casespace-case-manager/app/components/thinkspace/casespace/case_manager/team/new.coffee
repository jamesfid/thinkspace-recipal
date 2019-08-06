import ember from 'ember'
import ta    from 'totem/ds/associations'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import util from 'totem/util'
import totem_scope from 'totem/scope'
import base from './form'

export default base.extend
  # Properties
  title:  null
  color:  null
  is_new: true

  css_style: ember.computed 'color', ->
    color = @get 'color'
    return '' unless ember.isPresent(color)
    css = ''
    css += "background-color: ##{color};"
    new ember.Handlebars.SafeString css

  get_model: -> 
    new ember.RSVP.Promise (resolve, reject) =>
      team = @get_store().createRecord ns.to_p('team'),
        authable_type:              totem_scope.standard_record_path @get('space')
        authable_id:                parseInt @get('space.id')
        'thinkspace/team/team_set': @get('team_set')
      @set 'model', team
      resolve(team)

  transition_from_save: (team) -> @get('team_manager').transition_to_team_set_show(team)