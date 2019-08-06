import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'

export default ember.ObjectController.extend

  team_route:      ember.computed.reads 'parentController.team_route'
  all_teams:       ember.computed.reads 'parentController.all_teams'
  all_team_users:  ember.computed.reads 'parentController.all_team_users'
  team_categories: ember.computed.reads 'parentController.team_categories'

  # ### Team Categories.

  team_category_sort_by: ['title']
  team_categories_sorted: ember.computed.sort 'team_categories', 'team_category_sort_by'

  # ### Teams.

  collaboration_category:  ember.computed -> @store.all(ns.to_p 'team_category').findBy 'is_collaboration'
  peer_review_category:    ember.computed -> @store.all(ns.to_p 'team_category').findBy 'is_peer_review'

  team_sort_by: ['title']
  all_teams_sorted: ember.computed.sort 'all_teams', 'team_sort_by'

  team_filter_category: null
  all_teams_filtered_by_category: ember.computed.filter 'all_teams_sorted', (team) ->
    filter_id = @get('team_filter_category.id')
    return true unless filter_id
    team.get('category_id') == filter_id

  all_collaboration_teams: ember.computed 'all_teams_filtered_by_category', ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('all_teams').then =>
        @set_team_filter_category @get('collaboration_category')
        resolve @get 'all_teams_filtered_by_category'
    ds.PromiseArray.create promise: promise

  set_team_filter_category: (category) ->
    @set 'team_filter_category', category
    @notifyPropertyChange 'all_teams_sorted'

  # ### Helpers.

  polymorphic_type_to_path: (type) -> @totem_scope.rails_polymorphic_type_to_path(type)

  record_is_polymorphic: (record, polymorphic_record, key) ->
    record_path      = @totem_scope.get_record_path(record)
    polymorphic_path = @totem_scope.rails_polymorphic_type_to_path(polymorphic_record.get "#{key}_type")
    polymorphic_path == record_path and polymorphic_record.get("#{key}_id") == parseInt(record.get 'id')

  transition_to_index: -> @transitionToRoute @get('team_route.index')
