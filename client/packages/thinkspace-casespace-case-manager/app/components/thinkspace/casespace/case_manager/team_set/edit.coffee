import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  # Properties
  title: ember.computed.reads 'model.title'
  space: ember.computed.reads 'model.space'

  # Components
  c_space_header:  ns.to_p 'space', 'header'

  # Routes
  r_team_sets: ns.to_r 'case_manager', 'team_sets', 'index'

  # Upstream actions
  transition_to_team_set_show:  'transition_to_team_set_show'
  transition_to_team_set_index: 'transition_to_team_set_index'

  actions:
    save: ->
      model = @get 'model'
      model.set 'metadata', {} # Avoid the cyclic object issue.
      model.set 'title', @get('title')
      @totem_messages.show_loading_outlet(message: 'Saving team set...')
      model.save().then (team_set) =>
        team_set.get(ns.to_p('space')).then (space) =>
          @sendAction 'transition_to_team_set_show', space, team_set
          @totem_messages.hide_loading_outlet()

    destroy: ->
      model = @get 'model'
      @totem_messages.show_loading_outlet(message: 'Deleting team set...')
      model.destroyRecord().then =>
        @sendAction 'transition_to_team_set_index'
        @totem_messages.hide_loading_outlet()
