import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  space: ember.computed.reads 'model'
  title: null

  # Components
  c_space_header:  ns.to_p 'space', 'header'

  # Routes
  r_team_sets: ns.to_r 'case_manager', 'team_sets', 'index'

  # Upstream actions
  transition_to_team_set_show: 'transition_to_team_set_show'

  get_store: -> @container.lookup('store:main')

  actions:
    save: ->
      space    = @get 'space'
      team_set = @get_store().createRecord ns.to_p('team_set'),
        title: @get('title')
        space: space

      team_set.save().then (team_set) =>
        @sendAction 'transition_to_team_set_show', space, team_set