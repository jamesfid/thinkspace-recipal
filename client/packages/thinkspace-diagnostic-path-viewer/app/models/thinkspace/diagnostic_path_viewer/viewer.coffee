import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.polymorphic 'ownerable'
    ta.belongs_to 'path'
  ),
  
  user_id:        ta.attr('number')
  path_id:        ta.attr('number')
  ownerable_id:   ta.attr('number')
  ownerable_type: ta.attr('string')

  tvo: ember.inject.service()

  top_level_path_items: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('tvo.helper').load_ownerable_view_records(@).then =>
        @get('ownerable').then (ownerable) =>
          resolve @filtered_path_items(ownerable).sortBy 'position'
    ta.PromiseArray.create promise: promise

  viewer_path: ember.computed 'path_id', ->
    ta.PromiseObject.create
      promise: @get('top_level_path_items').then =>
        @store.find(ta.to_p('path'), @get('path_id')).then (path) =>
          title: path.get('title')

  ownerable_top_level_path_items: ember.computed ->
    promise = new ember.RSVP.Promise (resolve, reject) =>
      @get('tvo.helper').load_ownerable_view_records(@, sub_action: 'ownerable').then =>
        ownerable = @totem_scope.get_ownerable_record()
        resolve @filtered_path_items(ownerable).sortBy 'position'
    ta.PromiseArray.create promise: promise

  filtered_path_items: (ownerable) ->
    path_id   = @get('path_id')
    @store.all(ta.to_p 'path_item').filter (item) => 
      return false unless item.get('path_id') == path_id
      return false if     item.get('parent_id')
      @totem_scope.record_ownerable_match_ownerable(item, ownerable)
