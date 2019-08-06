import ember from 'ember'
import ns    from 'totem/ns'
import ajax           from 'totem/ajax'
import totem_error    from 'totem/error'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

# Delta object:
# If type is 'original', all values are the original values of the item(s) before any moevs.
# If type is 'future', all values are the post-change reflected state (e.g. after the move, but before data is synced/saved).

# TYPE.item.record     = <Model> # The record that was dragged, resolved.
# TYPE.item.is_new     = [false|TRUE] # If the record is a newly created record to be saved.
# TYPE.parent.record   = <Model> # The record's parent
# TYPE.parent.children = [<Model>, <Model>, ...] # The original parent record's children
# TYPE.position        = INT # The original position value of the record

export default ember.Object.extend

  debug: true

  init: (path, event, item=null) ->
    @set 'path',     path
    @set 'event',    event
    @set 'original', {}
    @set 'future',   {}
    @set 'changes',  {}
    @set 'status',   {}
    if ember.isPresent(item)
      @set 'item',  item 
      @set 'is_new', true

  process: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @parse_jquery_sortable_data()
      @get_dragged_item().then (item) =>
        @set('dragged_item', item)
        promises = @get_parent_sibling_promises()
        ember.RSVP.hash(promises).then (results) =>
          promises = @get_children_promises(results)
          ember.RSVP.hash(promises).then (children_results) =>
            original                 = {}
            original.item            = { record: item }
            original.item.is_new     = @get('is_new')
            original.parent          = { record: results.original_parent }
            original.parent.children = children_results.original_parent_children.sortBy('position') if ember.isPresent(children_results.original_parent_children)
            original.position        = item.get('position')

            future                 = {}
            future.parent          = {record: results.future_parent}
            future.parent.children = children_results.future_parent_children.sortBy('position') if ember.isPresent(children_results.future_parent_children)
            future.sibling         = results.future_sibling
            future.position        = results.future_sibling.get('position') + 1 if ember.isPresent(results.future_sibling)
            future.position        = 0 unless ember.isPresent(results.future_sibling) # First in list.

            @set 'original', original
            @set 'future', future
            @set_status()
            resolve()

  ##### Helpers
  set_status: ->
    status            = 'no_change'
    original_parent   = @get('original.parent.record')
    future_parent     = @get('future.parent.record')
    original_position = @get('original.position')
    future_position   = @get('future.position')
    original_item     = @get('original.item.record')

    switch
      when ember.isEqual(original_parent, future_parent) and @get('is_new')
        status = 'add_new_item'
      when ember.isEqual(original_parent, future_parent) and (future_position > original_position)
        status = 'reorder_item_down'
      when ember.isEqual(original_parent, future_parent) and (future_position < original_position)
        status = 'reorder_item_up'
      when ember.isEqual(original_item, future_parent)
        status = 'self_drop'
      when not ember.isEqual(original_parent, future_parent)
        status = 'move_item'

    console.info "[jquery-sortable Delta] Status detected as: [#{status}]" if @get('debug')
    @set 'status', status

  get_item_from_id: (id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) unless ember.isPresent(id)
      @get('path').store.find(ns.to_p('path_item'), id).then (item) =>
        resolve(item)

  get_dragged_item: ->
    new ember.RSVP.Promise (resolve, reject) =>
      item = @get('item')
      return resolve(item) if ember.isPresent(item)
      id = @get('dragged_item_id')
      @get_item_from_id(id).then (item) =>
        resolve(item)

  get_parent_sibling_promises: ->
    promises =
      original_parent: @get_item_from_id(@get('dragged_item.parent_id'))
      future_parent:   @get_item_from_id(@get('future_parent_id'))
      future_sibling:  @get_item_from_id(@get('future_sibling_id'))

  get_children_promises: (results) ->
    path                              = @get('path')
    promises                          = {}
    promises.original_parent_children = results.original_parent.get(ns.to_p('path_items')) if ember.isPresent(results.original_parent)
    promises.future_parent_children   = results.future_parent.get(ns.to_p('path_items')) if ember.isPresent(results.future_parent)
    promises.original_parent_children = path.get('children') unless ember.isPresent(results.original_parent)
    promises.future_parent_children   = path.get('children') unless ember.isPresent(results.future_parent)
    promises

  ##### jQuery Sortable
  parse_jquery_sortable_data: ->
    event           = @get('event')
    item            = @get('item')
    drop_container  = event.dropped_container
    $future_parent  = $(drop_container.el).parents('li').first()
    $future_sibling = $(drop_container.prevItem)

    @set 'drop_container',    drop_container
    @set 'future_parent_id',  $future_parent.attr('model_id') if ember.isPresent($future_parent)
    @set 'future_sibling_id', $future_sibling.attr('model_id') if ember.isPresent($future_sibling)
    if ember.isPresent(item) then @set('dragged_item_id', null) else @set('dragged_item_id', $(event.currentTarget).attr('model_id'))